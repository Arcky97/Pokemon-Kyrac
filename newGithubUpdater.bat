@echo off
color a
set /p message=[message]
git add .
git status
git commit -m %message%
git push
set /p done=[done]
exit