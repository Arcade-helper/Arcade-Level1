gcloud scc muteconfigs create muting-flow-log-findings \
  --project=$DEVSHELL_PROJECT_ID \
  --location=global \
  --description="Rule for muting VPC Flow Logs" \
  --filter="category=\"FLOW_LOGS_DISABLED\"" \
  --type=STATIC

gcloud scc muteconfigs create muting-audit-logging-findings \
  --project=$DEVSHELL_PROJECT_ID \
  --location=global \
  --description="Rule for muting audit logs" \
  --filter="category=\"AUDIT_LOGGING_DISABLED\"" \
  --type=STATIC

gcloud scc muteconfigs create muting-admin-sa-findings \
  --project=$DEVSHELL_PROJECT_ID \
  --location=global \
  --description="Rule for muting admin service account findings" \
  --filter="category=\"ADMIN_SERVICE_ACCOUNT\"" \
  --type=STATIC

gcloud compute firewall-rules delete default-allow-rdp

gcloud compute firewall-rules create default-allow-rdp \
  --source-ranges=35.235.240.0/20 \
  --allow=tcp:3389 \
  --description="Allow HTTP traffic from 35.235.240.0/20" \
  --priority=65534

gcloud compute firewall-rules delete default-allow-ssh --quiet

gcloud compute firewall-rules delete default-allow-ssh --quietgcloud compute firewall-rules create default-allow-ssh \
  --source-ranges=35.235.240.0/20 \
  --allow=tcp:22 \
  --description="Allow HTTP traffic from 35.235.240.0/20" \
  --priority=65534

export ZONE=$(gcloud compute project-info describe \
--format="value(commonInstanceMetadata.items[google-compute-default-zone])")

echo "${CYAN_TEXT}${BOLD_TEXT}OPEN THIS LINK: ${RESET_FORMAT}${BLUE_TEXT}${BOLD_TEXT}https://console.cloud.google.com/compute/instancesEdit/zones/$ZONE/instances/cls-vm?project=$DEVSHELL_PROJECT_ID${RESET_FORMAT}"

read -p "${RED_TEXT}${BOLD_TEXT}Have you followed the video steps (Y/N)? ${RESET_FORMAT}" response
if [[ "$response" =~ ^[Yy]$ ]]; then
  echo "${GREEN_TEXT}${BOLD_TEXT}Great! Let's Continue with the next Process.${RESET_FORMAT}"
else
  echo "${RED_TEXT}${BOLD_TEXT}Please follow the video steps before continuing to the Next Step.${RESET_FORMAT}"
fi

export ZONE=$(gcloud compute project-info describe \
--format="value(commonInstanceMetadata.items[google-compute-default-zone])")

export REGION=$(echo "$ZONE" | cut -d '-' -f 1-2)

export VM_EXT_IP=$(gcloud compute instances describe cls-vm --zone=$ZONE \
  --format='get(networkInterfaces[0].accessConfigs[0].natIP)')

gsutil mb -p $DEVSHELL_PROJECT_ID -c STANDARD -l $REGION -b on gs://scc-export-bucket-$DEVSHELL_PROJECT_ID

gsutil uniformbucketlevelaccess set off gs://scc-export-bucket-$DEVSHELL_PROJECT_ID

curl -LO raw.githubusercontent.com/ArcadeCrew/Google-Cloud-Labs/refs/heads/main/Mitigate%20Threats%20and%20Vulnerabilities%20with%20Security%20Command%20Center%20Challenge%20Lab/findings.jsonl

gsutil cp findings.jsonl gs://scc-export-bucket-$DEVSHELL_PROJECT_ID

echo "${CYAN_TEXT}${BOLD_TEXT}OPEN THIS LINK: ${RESET_FORMAT}${BLUE_TEXT}${BOLD_TEXT}https://console.cloud.google.com/security/web-scanner/scanConfigs/edit?project=$DEVSHELL_PROJECT_ID${RESET_FORMAT}"
echo "${YELLOW_TEXT}${BOLD_TEXT}COPY THIS: ${RESET}${GREEN_TEXT}${BOLD_TEXT}http://$VM_EXT_IP:8080${RESET_FORMAT}"

  
