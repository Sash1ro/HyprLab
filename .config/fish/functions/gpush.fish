#!/usr/bin/env fish

function gpush
    git add .
    git commit -m "$argv"
    git push
end
