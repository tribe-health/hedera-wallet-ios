#!/usr/bin/env sh
#   Copyright 2019 Hedera Hashgraph LLC
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.
#

####################
# Script constants #
####################


# Script version, which is a semantic versioning string.
SEMVER="0.1.0"

# Usage string roughly follows 'docopt' spec 0.6.
USAGE="$0: Run test commands.

Usage:
  $0 [options]
  $0 simulator_uuid [-h|--help]

Options:
  -h | --help  Output this message.
  --version    Output the version number.

Examples:
  $0 --help
  $0 --version
  $0 simulator_uuid -h
"

# Parameter types
PARAM_NOT_OPTION=0
PARAM_SHORT_OPTION=1
PARAM_LONG_OPTION=2


#############
# Functions #
#############


read_param_type() {
    PARAM="$1"
    LEN=`printf '%s' "$PARAM" | wc -c`
    if [ $LEN -ge 2 -a "`printf '%s' "$PARAM" | cut -c1-2`" = '--' ] ; then
        printf '%d' $PARAM_LONG_OPTION
    elif [ $LEN -eq 2 -a "`printf '%s' "$PARAM" | cut -c1`" = '-' ] ; then
        printf '%d' $PARAM_SHORT_OPTION
    else
        printf '%d' $PARAM_NOT_OPTION
    fi
}

READ_OPTION_HELP=0
READ_OPTION_VERSION=0
read_options() {
    SHIFTED=0
    READ_OPTION_HELP=0
    READ_OPTION_VERSION=0
    while : ; do
        PARAM_TYPE=`read_param_type "$1"`
        case $PARAM_TYPE in
            $PARAM_SHORT_OPTION) {
                if [ "$1" = '-h' ] ; then
                    READ_OPTION_HELP=1
                else
                    printf '\nInvalid short option "%s".\n' "$1" >&2
                    READ_OPTION_HELP=2
                fi
            };;
            $PARAM_LONG_OPTION) {
                if [ "$1" = '--help' ] ; then
                    READ_OPTION_HELP=1
                elif [ "$1" = '--version' ] ; then
                    READ_OPTION_VERSION=1
                else
                    printf '\nInvalid long option "%s".\n' "$1" >&2
                    READ_OPTION_HELP=2
                fi
            };;
            *) {
                break
            };;
        esac
        shift
        SHIFTED=`expr $SHIFTED + 1`
    done
    return $SHIFTED
}

reject_excess_parameters() {
    if [ $# -ne 0 ] ; then
        LC=`printf '%s' "$1" | wc -c`
        W2=`printf '%s' "$1" | cut -c2`
        W1=`printf '%s' "$W2" | cut -c1`
        if [ "$W2" = '--' ] ; then
            printf 'Options not allowed after positional parameters.\n' >&2
        elif [ "$LC" -eq 2 -a "$W1" = '-' ] ; then
            printf 'Options not allowed after positional parameters.\n' >&2
        else
            printf 'No further positional paramaters allowed.\n' >&2
        fi
        return 1
    fi
    return 0
}

possibly_show_help() {
    SHOW_HELP=$1
    SHOW_USAGE="$2"
    case $SHOW_HELP in
        1) {
            printf '%s\n' "$SHOW_USAGE"
            exit 0
        };;
        0) {
            :
        };;
        2|*) {
            printf '\nPrinting usage.\n\n%s\n' "$SHOW_USAGE" >&2
            exit 2
        };;
    esac
}


########
# Body #
########


#
# Read parameters.
#

read_options "$@"
shift $?
HELP=$READ_OPTION_HELP
VERSION=$READ_OPTION_VERSION

# Read command.
COMMAND=""
if [ $# -gt 0 ] ; then
    COMMAND="$1"
    shift
else
    # Default command is currently '--help'.
    COMMAND='--help'
fi


#
# Perform commands.
#


perform_version() {
    printf "%s\n" "$SEMVER"
}

perform_simulator_uuid() {
    CMD_USAGE="$0 simulator_uuid: Find a simulator UUID.

Usage:
  $0 simulator_uuid (-h|--help)

Options:
    -h|--help    Output this message.

Examples:
  $0 simulator_uuid
  $0 simulator_uuid -h
"

    #
    # Read parameters.
    #

    # Read optional parameters.
    read_options "$@"
    shift $?
    CMD_HELP=$READ_OPTION_HELP
    if [ $READ_OPTION_VERSION -ne 0 ] ; then
        printf '\nVersion option not supported by command.\n' >&2
        CMD_HELP=2
    fi

    # Reject excess parameters, if any.
    reject_excess_parameters "$@"
    if [ $? -ne 0 ] ; then
        CMD_HELP=2
    fi

    # Command not yet supported.
    if [ $CMD_HELP -eq 0 ] ; then
        CMD_HELP=1
    fi

    possibly_show_help $CMD_HELP "$CMD_USAGE"
}

# Note that -h and --help are promoted to commands if provided as a script
# option, and override any other behavior.
if [ $HELP -eq 0 ] ; then
    # Version is promoted to a command overrides any other command.
    if [ $VERSION -ne 0 ] ; then
        COMMAND='version'
    fi
    case $COMMAND in
        '--help') {
            HELP=1
        };;
        'version') {
            perform_version
        };;
        'simulator_uuid') {
            perform_simulator_uuid "$@"
        };;
        *) {
            printf '\nInvalid command "%s".\n' "$COMMAND" >&2
            HELP=2
        };;
    esac
fi

possibly_show_help $HELP "$USAGE"
