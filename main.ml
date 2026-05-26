open Effect
open Effect.Deep

type state =
  | Initial
  | Available
  | Reserved
  | Running

type error = InvalidStateTransition of state * state

let string_of_state = function
  | Initial -> "Initial"
  | Available -> "Available"
  | Reserved -> "Reserved"
  | Running -> "Running"


let string_of_error = function
  | InvalidStateTransition (state, new_state) ->
    Printf.sprintf
      "Invalid state transition: %s -> %s"
      (string_of_state state)
      (string_of_state new_state)


let state = ref Initial

type _ Effect.t +=
  | GetState : state Effect.t
  | UpdateState : state -> state Effect.t
  | Log : string -> unit Effect.t
  | Reject : error -> unit Effect.t

(*
  Initial -> Available
  Available -> Reserved
  Available -> Running
  Reserved -> Running
  Reserved -> Available
  Running -> Available
*)
let validate_state_transition state new_state : (state, error) result =
  match state, new_state with
  | Initial, Available -> Ok Available
  | Available, Reserved -> Ok Reserved
  | Available, Running -> Ok Running
  | Reserved, Running -> Ok Running
  | Reserved, Available -> Ok Available
  | Running, Available -> Ok Available
  | _ -> Error (InvalidStateTransition (state, new_state))


let update_state new_state =
  match validate_state_transition (perform GetState) new_state with
  | Ok new_state ->
    let state = perform (UpdateState new_state) in
    perform (Log (Printf.sprintf "State %s" (string_of_state state)));
    Ok new_state
  | Error err ->
    perform (Log (Printf.sprintf "Error: %s" (string_of_error err)));
    perform (Reject err);

    (* これ意味ない?まあでもRejectがcontinueするかどうかあまり意識したくないしいいか *)
    Error err


let app () =
  update_state Available
  |> Result.map (fun _ -> update_state Reserved)
  |> Result.map (fun _ -> update_state Running)
  |> Result.map (fun _ -> update_state Available)


let main () =
  match app () with
  | Ok _ -> Printf.printf "Done.\n"
  | Error _ -> Printf.printf "Done with Error.\n"
  | effect GetState, k -> continue k !state
  | effect UpdateState new_state, k ->
    state := new_state;
    continue k !state
  | effect Log msg, k ->
    Printf.printf "%s\n" msg;
    continue k ()
  | effect Reject err, _ -> Printf.printf "Rejected: %s.\n" (string_of_error err)


let () = main ()
