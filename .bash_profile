[ -f /etc/profile ] && source /etc/profile
PGDATA=/var/lib/pgsql/9.3/data
export PGDATA
PGPORT=5433
export PGPORT
export PAGER=less
export LESS="-iMSx4 -FX"
PATH=$PATH:/usr/pgsql-9.3/bin
export PATH
PERL5LIB='/usr/local/lib/perl5'
export PERL5LIB
PS1='[\t][\j][\u@\h:\W]\$ '
export PS1
