open Effect
open Effect.Deep

type state =
  | Preparing
  | Available
  | Reserved
  | Running

type error = InvalidStateTransition of state * state

let string_of_state = function
  | Preparing -> "Preparing"
  | Available -> "Available"
  | Reserved -> "Reserved"
  | Running -> "Running"


let string_of_error = function
  | InvalidStateTransition (state, new_state) ->
    Printf.sprintf
      "Invalid state transition: %s -> %s"
      (string_of_state state)
      (string_of_state new_state)


type _ Effect.t +=
  | GetState : state Effect.t
  | UpdateState : state -> state Effect.t
  | Log : string -> unit Effect.t
  | Reject : error -> unit Effect.t

(*
  Preparing -> Available
  Available -> Reserved
  Available -> Running
  Reserved -> Running
  Reserved -> Available
  Running -> Available
*)
let validate_state_transition state new_state : (state, error) result =
  match state, new_state with
  | Preparing, Available -> Ok Available
  | Available, Reserved -> Ok Reserved
  | Available, Running -> Ok Running
  | Reserved, Running -> Ok Running
  | Reserved, Available -> Ok Available
  | Running, Available -> Ok Available
  | _ -> Error (InvalidStateTransition (state, new_state))


let update_state new_state =
  let current_state = perform GetState in
  match validate_state_transition current_state new_state with
  | Ok new_state ->
    let state = perform (UpdateState new_state) in
    perform
      (Log
         (Printf.sprintf
            "State %s -> %s"
            (string_of_state current_state)
            (string_of_state state)))
  | Error err ->
    perform (Log (Printf.sprintf "Error: %s" (string_of_error err)));
    perform (Reject err)


let state = ref Preparing

let app_effect_handler (type a) (eff : a Effect.t) =
  match eff with
  | GetState -> Some (fun (k : (a, _) continuation) -> continue k !state)
  | UpdateState new_state ->
    Some
      (fun (k : (a, _) continuation) ->
        state := new_state;
        continue k !state)
  | Log msg ->
    Some
      (fun (k : (a, _) continuation) ->
        Printf.printf "[log] %s\n" msg;
        continue k ())
  | Reject err ->
    Some
      (fun (_k : (a, _) continuation) ->
        Printf.printf "Rejected: %s.\n" (string_of_error err))
  | _ -> None


let app_handler =
  { retc = (fun () -> Printf.printf "Done.\n"); exnc = raise; effc = app_effect_handler }


let app () =
  update_state Available;
  update_state Reserved;
  update_state Running;
  update_state Available


let () = match_with app () app_handler
