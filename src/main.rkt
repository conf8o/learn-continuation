#! /usr/local/bin/racket
#lang racket/base
(require racket/control racket/string)

; --- lib ---

; ```
; Initial -> Available
; Available -> Reserved
; Reserved -> Running
; Running -> Available
; Reserved -> Available
; Available -> Running
; ```
(define (valid-state-transition state new-state)
  (or (and (string=? state "Initial") (string=? new-state "Available"))
      (and (string=? state "Available") (string=? new-state "Reserved"))
      (and (string=? state "Reserved") (string=? new-state "Running"))
      (and (string=? state "Running") (string=? new-state "Available"))
      (and (string=? state "Reserved") (string=? new-state "Available"))
      (and (string=? state "Available") (string=? new-state "Running"))))

(define (update-state state new-state)
  (if (valid-state-transition state new-state)
      new-state
      "InvalidTransition"))

(define (is-error s) (string=? s "InvalidTransition"))

; --- main ---

(define state "Initial")
(define error-state #f)

(define (handle-state! result)
  (if (is-error result)
      (set! error-state result)
      (set! state result)))

(define (log . messages)
  (displayln (string-join (cons "[log]" messages))))

; 保存するやつ
(define update-state! #f)
(define (initialize)
  (reset
    (let ([requested-state (shift update
                             (set! update-state! update)
                             (update "Available"))])
      (log "request:" state "->" requested-state)

      (handle-state! (update-state state requested-state))

      (if error-state
          (log "error on update state:" error-state)
          (log "updated:" requested-state)))))

; 大域脱出
(define (app)
  (let/cc raise

    (initialize)
    (when error-state (raise error-state))

    (update-state! "Reserved")
    (when error-state (raise error-state))

    (update-state! "Running")
    (when error-state (raise error-state))

    (update-state! "Available")
    (when error-state (raise error-state))

    (raise "Done")))

(let ([app-result (app)])
  (if (is-error app-result)
      (log "error on app: " app-result)
      (log app-result)))
