for f in {1..1};
do tmux -2u new -d -n t$f -s t$f "proxychains4 -q Rscript do_scrape.R $f 2>&1 | tee ./log/t$f.log";
done
#+end_src

for f in {1..1};
do tmux kill-session -t t$f;
done
