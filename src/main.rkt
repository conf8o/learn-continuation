#! /usr/local/bin/racket
#lang racket/base
(require racket/control racket/match racket/string)

; --- lib ---

; ```
; Preparing -> Available
; Preparing -> Reserved
; Available -> Preparing
; Available -> Reserved
; Available -> Running
; Reserved -> Preparing
; Reserved -> Available
; Reserved -> Running
; Running -> Preparing
; ```
(define (valid-state-transition state new-state)
  (match (list state new-state)
    [(list "Preparing" "Available") #t]
    [(list "Preparing" "Reserved") #t]
    [(list "Available" "Preparing") #t]
    [(list "Available" "Reserved") #t]
    [(list "Available" "Running") #t]
    [(list "Reserved" "Preparing") #t]
    [(list "Reserved" "Available") #t]
    [(list "Reserved" "Running") #t]
    [(list "Running" "Preparing") #t]
    [_ #f]))

(define (update-state state new-state)
  (if (valid-state-transition state new-state)
      new-state
      "InvalidTransition"))

(define (is-error s) (string=? s "InvalidTransition"))

; --- main ---

(define state "Preparing")


; set! で継続を保存するやつ with 限定継続
; これが実用的だとは思えないけど理解のためには使えるか
; shiftの式より後の処理からresetまでの処理が `update` に束縛される
(define update-state! #f)

(define error-state #f)

(define (handle-state! result)
  (if (is-error result)
      (set! error-state result)
      (set! state result)))

(define (display-log . messages)
  (displayln (string-join (cons "[log]" messages))))


(define (initialize)
  (reset
    (let ([requested-state (shift update
                             (set! update-state! update)
                             (update "Available"))])
      (display-log "request:" state "->" requested-state)

      (handle-state! (update-state state requested-state))

      (if error-state
          (display-log "error on update state:" error-state)
          (display-log "updated:" requested-state)))))

; 全域継続 let/cc
; call/cc の糖衣構文
(define (app)
  (let/cc return

    (initialize)
    (when error-state (return error-state))

    (update-state! "Reserved")
    (when error-state (return error-state))

    (update-state! "Running")
    (when error-state (return error-state))

    (update-state! "Preparing")
    (when error-state (return error-state))

    (return "Done")))

(let ([app-result (app)])
  (if (is-error app-result)
      (display-log "error on app: " app-result)
      (display-log app-result)))


; 限定継続
(define (get-state)
  (shift k (k state)))

(define (put-state new-state)
  (shift k
    (set! state new-state)
    (k state)))

(define (log . messages)
  (shift k
    (displayln (string-join (cons "[log]" messages)))
    (k state)))

(define (reject err)
  (shift _
    (displayln (string-append "Rejected: " err))))


(define (update-state-delimited-cc new-state)
  (let* ([current-state (get-state)]
         [res (update-state current-state new-state)])
    (match res
      ["InvalidTransition"
       (begin
         (log "error: InvalidTransition")
         (reject "InvalidTransition"))]
      [s
       (begin
         (put-state s)
         (log "state updated: " s))])))

(define (app-delimited)
  (reset
    (update-state-delimited-cc "Available")
    (update-state-delimited-cc "Reserved")
    (update-state-delimited-cc "Running")
    (update-state-delimited-cc "Preparing")))

(app-delimited)