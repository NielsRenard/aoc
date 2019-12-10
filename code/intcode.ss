(define (mode opcode param)
  (case (digit-at param opcode)
    ((1) 'immediate)
    ((2) 'relative)
    ((0) 'position)))

(define (cpu intcode)
  (define ip 0)
  (define relative-base 0)
  (define status 'ok)
  (define cache1 `#(,@intcode))
  (define cache2 (make-eq-hashtable))
  (define size (vector-length cache1))
  (define in '())
  (define out '())

  (define (ip! dx)
    (set! ip (+ ip dx)))

  (define (rb! dx)
    (set! relative-base (+ relative-base dx)))
  
  (define (store! addr val)
    (if (fx< addr size)
        (vector-set! cache1 addr val)
        (hashtable-set! cache2 addr val)))
  
  (define (ref addr)
    (if (fx< addr size)
        (vector-ref cache1 addr)
        (hashtable-ref cache2 addr 0)))
  
  (define (val opcode param)
    (case (digit-at param opcode)
      ((1) (ref (+ ip param)))
      ((2) (ref (+ relative-base (ref (+ ip param)))))
      ((0) (ref (ref (+ ip param))))))

  (define (addr opcode param)
    (case (digit-at param opcode)
      ((2) (+ relative-base (ref (+ ip param))))
      ((0) (ref (+ ip param)))
      ((1) (error 'machine-addr "addr is immediate" opcode param))))
  
  (define (step)
    (let ((op (ref ip)))
      (case (fxmod op 100)
        ((1) (store! (addr op 3) (+ (val op 1) (val op 2))) (ip! 4))
        ((2) (store! (addr op 3) (* (val op 1) (val op 2))) (ip! 4))
        ((3) (if (null? in) (set! status 'blocking-in)
                 (begin (set! status 'ok) (store! (addr op 1) (pop! in)) (ip! 2))))
        ((4) (set! status 'out) (push! (val op 1) out) (ip! 2))
        ((5) (if (zero? (val op 1)) (ip! 3) (set! ip (val op 2))))
        ((6) (if (zero? (val op 1)) (set! ip (val op 2)) (ip! 3)))
        ((7) (store! (addr op 3) (if (< (val op 1) (val op 2)) 1 0)) (ip! 4))
        ((8) (store! (addr op 3) (if (= (val op 1) (val op 2)) 1 0)) (ip! 4))
        ((9) (rb! (val op 1)) (ip! 2))
        ((99) (set! status 'done))
        (else (error 'intcode "bad opcode" op)))))

  (define (run)
    (step)
    (case status
      ((done blocking-in out) (void))
      (else (run))))
  
  (define (dump)
    `(ip ,ip rb ,relative-base in ,in out ,out status ,status))

  (define (mem)
    `(cache1 ,cache1 cache2 ,cache2))

  (define (reset!)
    (set! cache1 `#(,@intcode))
    (set! cache2 (make-eq-hashtable))
    (set! ip 0)
    (set! relative-base 0)
    (set! in '())
    (set! out '())
    (set! status 'ok))

  (define (swap! program)
    (set! intcode program))
  
  (lambda (me . args)
    (case me
      ((step) (step))
      ((in) (set! in `(,@in ,@args)) (set! status 'ok))
      ((out) (if (null? out) 'no-out (car out)))
      ((run) (run))
      ((status) status)
      ((dump) (dump))
      ((mem) (if (null? args) (mem) (map ref args)))
      ((set-mem!) (apply store! args))
      ((swap!) (apply swap! args))
      ((reset!) (reset!))
      ((ip) ip)
      ((rb) relative-base)
      (else (error 'cpu "unknown message" me)))))

(define (run-until-halt machine)
  (let run ()
    (machine 'step)
    (case (machine 'status)
      ((done blocking-in) (machine 'dump))
      (else (run)))))

(define (feed M N)
  (lambda ()
    (let run ()
      (M 'run)
      (case (M 'status)
        ((out) (N 'in (M 'out)) (N 'step) (run))
        ((blocking-in) 'blocked)
        ((done) 'done)
        (else (run))))))

(define (feedback-loop machines)
  (map feed machines `(,@(cdr machines) ,(car machines))))

(define (spew machine)
  (display-ln (machine 'dump))
  (let run ()
    (machine 'step)
    (display-ln (machine 'mem))  
    (display-ln (machine 'dump))
    (case (machine 'status)
      ((done)
       (display-ln 'done))
      ((blocking-in)
       (display-ln 'blocking-in))
      (else (run)))))

(define (log-control-flow M cutoff)
  (let run ((ips '()) (j 0))
    (let ((ips* (cons (M 'ip) ips)))
      (cond
       ((or (= j cutoff) (eq? 'done (M 'status)))
        (reverse ips*))
       (else
        (M 'step)
        (run ips* (1+ j)))))))



