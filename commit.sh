#!/usr/bin/env bash
# set -x

export JIRA_PROJECT_KEY="WOR"
export CHANGELOG_FILE="CHANGELOG"
export JIRA_URL="https://jira.beescloud.com"

# https://developer.atlassian.com/jiradev/jira-apis/jira-rest-apis/jira-rest-api-tutorials/jira-rest-api-example-create-issue

export FEATURE_DESC="Front feature $(date)"

export JIRA_ISSUE_AS_JSON=$(curl --silent --netrc -H "Content-Type: application/json" -X POST \
   --data "{\"fields\":{\"project\":{\"key\":\"$JIRA_PROJECT_KEY\"},\"summary\":\"$FEATURE_DESC\",\"description\":\"We are working on $FEATURE_DESC\",\"issuetype\":{\"name\":\"New Feature\"}}}" \
   $JIRA_URL/rest/api/2/issue/)


export JIRA_ISSUE=$(echo $JIRA_ISSUE_AS_JSON | jq -r .key)

echo "Issue $JIRA_URL/browse/$JIRA_ISSUE created: $FEATURE_DESC"

# TODO update issue, set status to "in progress"
# see https://docs.atlassian.com/jira/REST/server/?_ga=2.148590398.82631418.1503650538-983538049.1489593855#api/2/issue-doTransition

export COMMIT_MESSAGE="$JIRA_ISSUE Front feature change ..."

git pull

echo "$(date) [$JIRA_ISSUE] $COMMIT_MESSAGE" >> $CHANGELOG_FILE

git add $CHANGELOG_FILE
git commit -m "[$JIRA_ISSUE] $COMMIT_MESSAGE"

git push


echo "## SUCCESS #"
echo "Commit for $JIRA_URL/browse/$JIRA_ISSUE pushed"