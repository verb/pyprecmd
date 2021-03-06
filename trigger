#!/usr/bin/env python
#
# Copyright 2012-2013 Lee Verberne <lee@blarg.org>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
'''Subscribe to a message queue and do something with the messages'''

from __future__ import print_function

import argparse
import logging
import os
import shlex
import subprocess
import sys

import amqplib.client_0_8 as amqp

PROG='trigger'
try:
    from pyprecmd import VERSION
except ImportError:
    VERSION = "(unknown)"

def parse_arguments():
    "Parse arguments from command line invocation"
    pw_warn = '''Passwords specified via command line options will be visible
              from process lists such as those produced by ps(1).  One can
              avoid this by setting a password in the MQ_PASSWORD environment
              variable instead.'''
    parser = argparse.ArgumentParser(prog=PROG, description=__doc__,
                                     epilog=pw_warn)
    # Positional Arguments
    parser.add_argument('command', help="command to run when triggered")

    # Standard CLI Options
    parser.add_argument('-d', '--debug', action='store_const',
                        const=logging.DEBUG, dest='loglevel',
                        help="Enable debug messages")
    parser.add_argument('-v', '--verbose', action='store_const',
                        const=logging.INFO, dest='loglevel',
                        help="Enable verbose logging")
    parser.add_argument('-V', '--version', action='version', version=VERSION)

    # Connection Options
    amqp_g = parser.add_argument_group('AMQP Options')
    amqp_g.add_argument('--exchange', default='amq.topic',
                        help="Exchange to bind (default: amq.topic)")
    amqp_g.add_argument('--key', default='#',
                        help="Routing key for MQ topic (default: #)")
    amqp_g.add_argument('--password', default='guest',
                        help="MQ server password (default: guest)")
    amqp_g.add_argument('--server', default='localhost',
                        help="MQ server to connect (default: localhost)")
    amqp_g.add_argument('--userid', default='guest',
                        help="MQ server userid (default: guest)")
    amqp_g.add_argument('--vhost', default='/',
                        help="MQ server virtual host (default: /)")

    args = parser.parse_args()
    if 'MQ_PASSWORD' in os.environ:
        args.password = os.environ['MQ_PASSWORD']

    return args

def run_command(msg):
    "Runs a command for the given message"
    logging.debug("Received message %s", msg.delivery_info)
    logging.info("Running command %s", args.command)
    try:
        subprocess.check_output(shlex.split(args.command))
    except subprocess.CalledProcessError:
        # TODO: something...
        raise

def main():
    global args
    args = parse_arguments()
    if args.loglevel:
        logging.getLogger().setLevel(args.loglevel)
        logging.debug("%s version %s", PROG, VERSION)

    try:
        with amqp.Connection(args.server,
                             password=args.password,
                             userid=args.userid,
                             virtual_host=args.vhost) as conn:
            with conn.channel() as ch:
                ch_q, _, _ = ch.queue_declare()
                ch.queue_bind(ch_q, args.exchange, routing_key=args.key)
                ch.basic_consume(callback=run_command)
                logging.debug("Descending into infinite loop of infinity")
                try:
                    while True:
                        ch.wait()
                except KeyboardInterrupt:
                    logging.info("Caught interrupt, exiting.")
    except Exception as e:
        if args.loglevel == logging.DEBUG:
            raise
        else:
            sys.exit('Error: {0}'.format(e))

if __name__ == "__main__":
    main()
