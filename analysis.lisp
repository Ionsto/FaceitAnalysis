(ql:quickload :cl-json)
(ql:quickload :cl-strings)
(ql:quickload :drakma)
(defparameter jc-id "76561198040942941")
(defparameter regal-id "76561198062117176")
(defparameter ionsto-id "76561198022699947")
(defparameter json-file (merge-pathnames "faceit_history.json"))
(defclass game ()
  (
   (win :initarg :win)
   (team :initarg :team)
   )
  )
(defun get-names (faction)
  (loop for player in faction 
        collect (cdr (assoc :game-name player))
        ))
(defun get-id (faction)
  (loop for player in faction 
        collect (cdr (assoc :gameid player))
        ))
(defun process-game (game)
  (let* (
        (ionsto-team-id (cdr (assoc :i-2 game)))
        (players (cdr (assoc :teams game)))
        (ionsto-win (equal (equal ionsto-team-id (cdr (assoc :team-id (first players)))) (equal "1" (cdr (assoc :i-17 (first players))))))
        )
    (print(cdr (assoc :team-id (first players))))
;    (print ionsto-team-id)
;    (print players)
;    (print ionsto-win)
    ionsto-win
    )
  )
(defun get-data (id)
  (first (cl-json:decode-json-from-string 
          (octets-to-string (drakma:http-request (cl-strings:join (list "https://api.faceit.com/stats/v1/stats/matches/" id)))))))
(defun get-match-id (file-num)
  (let ((file-name (merge-pathnames (cl-strings:join (list "history/" (write-to-string file-num) ".json"))  )))
    (with-open-file (in file-name)
        (let ((data (json:decode-json in)))
          (loop for m in data
                collect (cdr (assoc :match-id m))
                )))))

(defparameter match-ids 
  (loop for i from 1 upto 21
        append (get-match-id i))) 
(dolist (id match-ids)
  (print (process-game (get-data id)))
  )
;(defparameter full-payload (loop for i from 1 upto 21
;    collect (with-open-file (in (merge-pathnames (cl-strings:join (list "history/" (write-to-string i) ".json"))))
;           (let ((data (json:decode-json in)))
;             (rest (assoc :payload data))
;             ))))
;(loop for game in full-payload
;       collect (process-game game))


