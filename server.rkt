#lang racket

(require web-server/servlet
         web-server/servlet-env
         web-server/dispatch
         web-server/templates
         net/uri-codec)

(define generate-html
  (lambda (raw-data)
    (cond
      [raw-data
        (let* ([raw-data-string (bytes->string/utf-8 raw-data)]
               [decoded-data (form-urlencoded-decode raw-data-string)]
               [decoded-list (form-urlencoded->alist raw-data-string)]
               [input (cdar decoded-list)]
               [textarea (cdadr decoded-list)])
          (include-template "index.html"))]
      [else
        (let ([raw-data ""]
              [decoded-data ""]
              [input ""]
              [textarea ""])
          (include-template "index.html"))])))

(define index
  (lambda (req)
    (response/output
      (lambda (out)
        (display
          (generate-html (request-post-data/raw req))
          out)))))

(define exception
  (lambda (req)
    (response/jsexpr "Error")))

(define-values (server-dispatch generate-url)
  (dispatch-rules
    [("") index]
    [("") #:method "post" index]
    [else exception]))

(define server
  (lambda (req)
    (server-dispatch req)))

(serve/servlet server
               #:command-line? #t
               #:listen-ip #f
               #:servlet-regexp #rx"")

