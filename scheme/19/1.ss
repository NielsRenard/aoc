(include "~/code/advent/load.ss")
(advent-year 19) (advent-day 1)

(define masses
  (parse-advent input))

(define (fuel mass)
  (- (fx/ mass 3) 2))

(define (fuel+ mass)
  (if (< 0 mass) (+ mass (fuel+ (fuel mass))) 0))

(define (part-a)
  (apply + (map fuel masses)))

(define (part-b)
  (apply + (map (compose fuel+ fuel) masses)))