Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser  
# download and expand the runner source
Invoke-WebRequest -Uri https://product-downloads.atlassian.com/software/bitbucket/pipelines/atlassian-bitbucket-pipelines-runner-3.16.0.zip -OutFile .\bitbucket-pipelines-runner.zip
Expand-Archive .\bitbucket-pipelines-runner.zip 
# copy the service installer and configuration file to the runner directory
Copy-Item .\ws-runner.exe .\bitbucket-pipelines-runner
Copy-Item .\ws-runner.xml .\bitbucket-pipelines-runner
# change to the runner directory
cd .\bitbucket-pipelines-runner

# Install the runner as a service
#.\ws-runner.exe install ws-runner.xml 
