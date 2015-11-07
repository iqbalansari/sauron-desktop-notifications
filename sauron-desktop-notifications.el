;; TODO: Proper parsing of dbus-monitor output
;;       Handler for user interactions
;;       Displaying icon 

(require 's)
(require 'sauron)

(defun sauron-desktop-notifications--dbus-monitor-filter (proc output)
  (when (string-match-p "member=Notify" output)
    (sauron-desktop-notifications--dbus-monitor-parse proc output)))

(defun sauron-desktop-notifications--parse-value (line)
  (read (s-join " "
                (cdr (s-split " " (s-trim line))))))

(defun sauron-desktop-notifications--dbus-monitor-parse (proc output)
  "Parse the output from dbus monitor."
  (let* ((lines (cdr (split-string output "\n")))
         (appname (sauron-desktop-notifications--parse-value (nth 0 lines)))
         (app-icon (sauron-desktop-notifications--parse-value (nth 2 lines)))
         (summary (sauron-desktop-notifications--parse-value (nth 3 lines)))
         (body (sauron-desktop-notifications--parse-value (nth 4 lines))))
    (sauron-add-event 'desktop-notification 4 (format "%s - %s" summary body))))

(defun sauron-desktop-notifications-start ()
  (set-process-filter (start-process "dbus-monitor" nil "dbus-monitor" "interface=org.freedesktop.Notifications,member=Notify")
                      #'sauron-desktop-notifications--dbus-monitor-filter))


(sauron-desktop-notifications-start)
