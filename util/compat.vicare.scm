(library
    (util compat)
  (export directory-list printf system unlink path-last path-root path-parent)
  (import
   (rnrs)
   (only (vicare) printf)
   (only (vicare posix) system unlink opendir readdir/string))

  (define (string-rfind s c)
    (let loop ((i (- (string-length s) 1)))
      (cond
        ((zero? i) #f)
        ((eq? (string-ref s i) c) i)
        (else (loop (- i 1))))))

  (define (path-root p)
    (let ((i (string-rfind p #\.)))
      (if i
          (substring p 0 i)
          p)))

  (define (path-last p)
    (let ((i (string-rfind p #\/)))
      (if i
          (substring p (+ i 1) (string-length p))
          p)))

  (define (path-parent p)
    (let ((i (string-rfind p #\/)))
      (if i
          (substring p 0 (+ i 1))
          p)))
  
  (define (directory-list path)
    (let ((dir (opendir path)))
      (let loop ((file (readdir/string dir)))
        (if file
            (cons file (loop (readdir/string dir)))
            '())))))
