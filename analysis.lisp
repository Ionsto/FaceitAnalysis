(ql:quickload :cl-json)
(ql:quickload :cl-strings)
(ql:quickload :drakma)
(defparameter jc-id"20778cc5-dde0-4333-8e13-efb5f2e6c317")
(defparameter regal-id "25de947c-1ea8-4052-a3a4-b6c439f9659b")
(defparameter ionsto-id "72457581-78d3-42a8-b01b-ec14ac2740e6")
(defparameter json-file (merge-pathnames "faceit_history.json"))
(defclass game ()
  (
   (win :initarg :win)
   (team :initarg :team)
   )
  )
(defstruct player-stat (win 0) (loss 0))
(defun get-names (team)
  (let ((faction (cdr (assoc :players team))))
    (loop for player in faction 
          collect (string-downcase (cdr (assoc :nickname player)))
          )))
(defun get-player-id (team)
  (let ((faction (cdr (assoc :players team))))
    (loop for player in faction 
          collect (cdr (assoc :player-id player))
          )))
(defun process-game (game)
  (let* (
        (winning-team-id (cdr (assoc :i-2 game)))
        (teams (cdr (assoc :teams game)))
        (team-1 (first teams))
        (team-2 (second teams))
        (ionsto-t1 (not (find "ionsto" (get-names team-2) :test #'equalp)))
        (ionsto-win (equal (not (find "ionsto" (get-names team-2) :test #'equalp)) (equal "1" (cdr (assoc :i-17 team-1)))))
        )
    (print (get-names team-1))
    (print (get-names team-2))
    (print ionsto-win)
    (list ionsto-win (get-player-id (if ionsto-t1 team-1 team-2)))
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
(defun win-loss (player matchstats)
  (let ((stats (make-player-stat)))
    ( dolist (match matchstats)
         (destructuring-bind (win players) match
            (when (find player (second match) :test #'equal)
              (if win 
                  (setf(player-stat-win stats) (+ 1 (player-stat-win stats)))
                  (setf(player-stat-loss stats) (+ 1 (player-stat-loss stats)))
                  ) 
              )
            ))
        stats
    )
  )
(print "Match ids")
(defparameter match-ids 
  (loop for i from 1 upto 21
        append (get-match-id i))) 
(print "Match data")
(defparameter match-data
  (loop for id in match-ids and idx from 0
        do (print idx)
        collect (get-data id))) 
(print "match stats")
(defparameter match-stats 
  (loop for data in match-data and idx from 0
        do (print idx)
        collect (process-game data))) 
(print "Win loss")
(print (win-loss ionsto-id match-stats))
(print (win-loss regal-id  match-stats))
(print (win-loss jc-id  match-stats))
;  )
;(defparameter full-payload (loop for i from 1 upto 21
;    collect (with-open-file (in (merge-pathnames (cl-strings:join (list "history/" (write-to-string i) ".json"))))
;           (let ((data (json:decode-json in)))
;             (rest (assoc :payload data))
;             ))))
;(loop for game in full-payload
;       collect (process-game game))


