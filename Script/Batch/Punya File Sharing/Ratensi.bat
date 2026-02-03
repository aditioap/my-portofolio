forfiles -p Z:\Backup-svr\Daily\file-share-incremental -s -d -7 -c "cmd /c if @isdir==FALSE echo @path"
exit