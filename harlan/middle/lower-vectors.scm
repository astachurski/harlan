(library
  (harlan middle lower-vectors)
  (export lower-vectors)
  (import
    (rnrs)
    (harlan helpers)
    (elegant-weapons helpers))

(define-match lower-vectors
  ((module ,[lower-decl -> decl*] ...)
   `(module . ,decl*)))

(define-match lower-decl
  ((fn ,name ,info ... ,[lower-stmt -> s])
   `(fn ,name ,info ... ,s))
  ((extern ,name ,args -> ,t)
   `(extern ,name ,args -> ,t)))

(define-match lower-stmt
  ((error ,x) `(error ,x))
  ((let ,b ,[s])
   (lower-lifted-expr b s))
  ((begin ,[stmt*] ...)
   (make-begin stmt*))
  ((if ,t ,[c])
   `(if ,t ,c))
  ((if ,t ,[c] ,[a])
   `(if ,t ,c ,a))
  ((while ,e ,[s])
   `(while ,e ,s))
  ((for (,i ,start ,end ,step) ,[stmt])
   `(for (,i ,start ,end ,step) ,stmt))
  ((set! ,lhs ,rhs)
   `(set! ,lhs ,rhs))
  ((return)
   `(return))
  ((return ,e)
   `(return ,e))
  ((assert ,e)
   `(assert ,e))
  ((print ,e* ...)
   `(print . ,e*))
  ((kernel ,t (,dims ...) ,fv* ,[stmt])
   `(kernel ,t ,dims ,fv* ,stmt))
  ((do ,e) `(do ,e)))

(define (lower-lifted-expr b s)
  (match b
    (() s)
    (((,x (vec ,t) (vector (vec ,t) . ,e*)) . ,[rest])
     `(let ((,x (vec ,t)
                (make-vector ,t (int ,(length e*)))))
        (begin
          ,@(let loop ((e* e*) (i 0))
              (if (null? e*)
                  `()
                  `((set! (vector-ref ,t
                                      (var (vec ,t) ,x)
                                      (int ,i))
                          ,(car e*))
                    . ,(loop (cdr e*) (+ 1 i)))))
          ,rest)))
    (((,x ,t ,e) . ,[rest])
     `(let ((,x ,t ,e)) ,rest))
    (((,x ,t) . ,[rest])
     `(let ((,x ,t)) ,rest))))

)