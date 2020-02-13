#!/usr/bin/env bash
# setup global variables
GCLOUD=/usr/bin/gcloud

usage() {
    echo -e "\nUsage: $0 [-u <user>] [-p <project_id>]" 1>&2
    echo -e "\nOptions:\n"
    echo -e "    -u    User email to use for iam policy"
    echo -e "    -p    Project ID to use."
    echo -e "          read in with gcloud if not specified [OPTIONAL]"
    echo -e "\n"
    exit 1
}

setScriptOptions() {
    while getopts ":u:p" opt; do
        case $opt in
            u)
                opt_u=${OPTARG}
                ;;
            p)
                opt_p=${OPTARG}
                ;;
            *)
                usage
                ;;
        esac
    done
    shift $((OPTIND-1))

    # user
    if [[ -n $opt_u ]]; then
        USER=$opt_u
    else
        echo -e "Missing email address to add"
        usage
        exit 1
    fi


    # gcloud Project
    if [[ -n $opt_p ]]; then
        PROJECT="--project $opt_p"
    else
        PROJECT=$(${GCLOUD} info --format='value(config.project)')
    fi
}

add_user(){
    ${GCLOUD} projects add-iam-policy-binding ${PROJECT} --role roles/storage.admin \
    --member user:${USER} --no-user-output-enabled

    # check status
    retVal=$?
    if [[ ${retVal} -ne 0 ]]; then
        echo -e "Adding user failed"
        echo -e "Try running manually and see what happens"
        echo -e "${GCLOUD} projects add-iam-policy-binding ${PROJECT} --role roles/storage.admin \
    --member user:${USER}"
        echo -e "\n"
        exit ${retVal}
    else
        echo -e "User ${USER} successfully added"
    fi

}

remove_user(){
    ${GCLOUD} projects remove-iam-policy-binding ${PROJECT} --role roles/storage.admin \
    --member user:${USER} --no-user-output-enabled

    # check status
    retVal=$?
    if [[ ${retVal} -ne 0 ]]; then
        echo -e "Removing user failed"
        echo -e "Try running manually and see what happens"
        echo -e "${GCLOUD} projects remove-iam-policy-binding ${PROJECT} --role roles/storage.admin \
    --member user:${USER}"
        echo -e "\n"
        exit ${retVal}
    else
        echo -e "User ${USER} successfully removed"
    fi
}

main (){
    # set script options
    setScriptOptions "$@"

    # add user
    add_user

    # remove user
    remove_user
}

main "$@"