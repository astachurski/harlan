(library
    (harlan middle make-kernel-dimensions-explicit)
  (export make-kernel-dimensions-explicit)
  (import
   (rnrs)
   (harlan helpers)
   (elegant-weapons helpers))

  (define-match make-kernel-dimensions-explicit
    ((module ,[Decl -> decl*] ...)
     `(module ,decl* ...)))
    
  (define-match Decl
    ((fn ,name ,args ,t ,[Stmt -> stmt])
     `(fn ,name ,args ,t ,stmt))
    ((extern ,name ,args -> ,rtype)
     `(extern ,name ,args -> ,rtype)))

  (define-match Stmt
    ((let ((,x* ,t* ,[Expr -> e*]) ...) ,[body])
     `(let ((,x* ,t* ,e*) ...) ,body))
    ((set! ,[Expr -> lhs] ,[Expr -> rhs])
     `(set! ,lhs ,rhs))
    ((vector-set! ,t ,[Expr -> v] ,[Expr -> i] ,[Expr -> e])
     `(vector-set! ,t ,v ,i ,e))
    ((if ,[Expr -> test] ,[conseq] ,[altern])
     `(if ,test ,conseq ,altern))
    ((if ,[Expr -> test] ,[conseq])
     `(if ,test ,conseq))
    ((while ,[Expr -> test] ,[body])
     `(while ,test ,body))
    ((for (,x ,[Expr -> start] ,[Expr -> stop]) ,[body])
     `(for (,x ,start ,stop) ,body))
    ((begin ,[stmt*] ...)
     `(begin ,stmt* ...))
    ((print ,[Expr -> e] ...)
     `(print . ,e))
    ((assert ,[Expr -> e])
     `(assert ,e))
    ((return) `(return))
    ((return ,[Expr -> e])
     `(return ,e))
    ((do ,[Expr -> e])
     `(do ,e)))

  (define-match Expr
    ((,t ,v) (guard (scalar-type? t)) `(,t ,v))
    ((var ,t ,x) `(var ,t ,x))
    ((int->float ,[e]) `(int->float ,e))
    ((iota ,[e]) `(iota ,e))
    ((vector ,t ,[e*] ...)
     `(vector ,t ,e* ...))
    ((make-vector ,t ,[e])
     `(make-vector ,t ,e))
    ((vector-ref ,t ,[v] ,[i])
     `(vector-ref ,t ,v ,i))
    ((length ,[e])
     `(length ,e))
    ((call ,[f] ,[args] ...)
     `(call ,f ,args ...))
    ((if ,[test] ,[conseq] ,[altern])
     `(if ,test ,conseq ,altern))
    ((if ,[test] ,[conseq])
     `(if ,test ,conseq))
    ((reduce ,t ,op ,[e])
     `(reduce ,t ,op ,e))
    ((kernel (vec ,n ,inner-type) (((,x ,t) (,[xs] ,ts))
                                   ((,x* ,t*) (,[xs*] ,ts*)) ...) ,[body])
     (let ((xs^ (gensym 'xs)))
       `(let ((,xs^ ,ts ,xs))
          (kernel (vec ,n ,inner-type)
                  ((length (var ,ts ,xs^)))
                  (((,x ,t) ((var ,ts ,xs^) ,ts) 0)
                   ((,x* ,t*) (,xs* ,ts*) 0) ...) ,body))))
    ((let ((,x* ,t* ,[e*]) ...) ,[e])
     `(let ((,x* ,t* ,e*) ...) ,e))
    ((begin ,[Stmt -> s*] ... ,[e])
     `(begin ,s* ... ,e))
    ((,op ,[lhs] ,[rhs])
     (guard (or (relop? op) (binop? op)))
     `(,op ,lhs ,rhs)))

  ;; end library
  )
