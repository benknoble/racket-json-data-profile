#lang racket

(require json
         racket/hash)

(command-line
  #:args (input [size 10000])
  (define base
    (with-input-from-file input
      read-json))

  (define object (hash-ref base (first (hash-keys base))))

  (define new-keys
    (for/list ([_ (range size)])
      (gensym "U")))

  (define new-json
    (apply hash-union base
           (map (curryr hash object) new-keys)))

  (let ([s (jsexpr->string new-json)])
    (time (string->jsexpr s)
          (void)))

  (display-lines-to-file
    (list (jsexpr->string new-json))
    "data.json"
    #:exists 'truncate))
