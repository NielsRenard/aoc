(load "~/code/advent/load.ss")
(advent-year 19)
(advent-day 7)

(define intcode
  (parse-advent comma-separated))

(define (day7 phase-settings intcode)
  (define-syntax define-network
    (lambda (x)
      (syntax-case x (=> <- >?)
        ((_ (A ...) ((x => y) ...) ((m <- phase) ...) (?> T) intcode)
         #'(let ((A (cpu intcode)) ...)
             (let ((loop (list (feed x y) ...)))
               (m 'in phase) ...
               (let run ()
                 (if (eq? 'done (T 'status))
                     (T 'out)
                     (let ((action (pop! loop)))
                       (let ((result (action)))
                         (unless (eq? result 'done)
                           (set! loop `(,@loop ,action)))
                         (run)))))))))))
  
  (let-values (((p h a s e) (apply values phase-settings)))
    (define-network (A B C D E)
      ((A => B) (B => C) (C => D) (D => E) (E => A))
      ((A <- p) (B <- h) (C <- a) (D <- s) (E <- e) (A <- 0))
      (>? E)
      intcode)))

(define (best-configuration phases)
  (define best 0)
  (for-all (lambda (phase-settings)
             (let ((out (day7 phase-settings intcode)))
               (when (< best out)
                 (set! best (max best out)))))
           (permutations phases))
  best)

(define (partA)
  (best-configuration '(0 1 2 3 4)))

(define (partB)
  (best-configuration '(5 6 7 8 9)))