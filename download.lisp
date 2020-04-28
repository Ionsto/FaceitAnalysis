(ql:quickload :drakma)
(defparameter path (merge-pathnames "faceit_history.json"))
(with-open-file (stream path :direction :output :if-exists :supersede)
  (format stream "hellow"))
;  (format stream (loop for x from 1 upto 21 collect
;                       (drakma:decode-stream (drakma:http-request "https://api.faceit.com/stats/v1/stats/time/users/72457581-78d3-42a8-b01b-ec14ac2740e6/games/csgo?page=1&size=30")) 
;                       )))

