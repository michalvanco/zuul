import os

from subprocess import Popen, PIPE


def git_version():
    command = ['git', '--version']
    env = os.environ.copy()
    cwd = os.getcwd()
    istream = None
    proc = Popen(command,
                 env=env,
                 cwd=cwd,
                 bufsize=-1,
                 stdin=istream,
                 stderr=PIPE,
                 stdout=PIPE,
                 shell=False,
                 close_fds=(os.name == 'posix'),  # unsupported on windows
                 )
    proc.communicate()


if __name__ == '__main__':
    for i in xrange(1000):
        git_version()
