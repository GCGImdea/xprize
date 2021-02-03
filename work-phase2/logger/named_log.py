import os
import logging


def named_log(loggerName):
    logging.basicConfig(
        filename=os.path.expanduser('~/work/prescripting.log'),
        format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
        level=logging.INFO,
        datefmt='%Y-%m-%d %H:%M:%S')

    return logging.getLogger(loggerName)
