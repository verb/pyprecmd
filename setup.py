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

from distutils.core import setup

VERSION = '0.1'

setup(name='pyprecmd',
      author='Lee Verberne',
      author_email='lee@blarg.org',
      description='Utilities that change the way commands are run.',
      license='GPLv3',
      scripts=['mq-trigger'],
      version=VERSION
     )
