# Install Bitbucket Runner on Windows

## Prerequisites

Check out the official docs and verify all dependencies are met:
[Set up runners for Windows](https://support.atlassian.com/bitbucket-cloud/docs/set-up-runners-for-windows/)

From administrator PowerShell console, run: `.\Install-Prerequisites.ps1`

This should install the prerequisites defined in [choco-packages](choco-packages.config)

## Configure and Prepare Runner

On the Bitbucket cloud web app, from the Runner section in the repository/workspace settings, add a runner and follow the wizard steps until the PowerShell script step.

Copy the `start.ps1` line and take note of parameters (account, repository, runner UUID and authentication).

## Running the Runner 'once'

Open a PowerShell terminal in the folder where you would like to install the runner (e.g., C:\Users\your_user_name\runners) and download the latest version of the runner. Example:

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser  
# download and expand the runner source
Invoke-WebRequest -Uri https://product-downloads.atlassian.com/software/bitbucket/pipelines/atlassian-bitbucket-pipelines-runner-3.16.0.zip -OutFile .\bitbucket-pipelines-runner.zip
Expand-Archive .\bitbucket-pipelines-runner.zip 

```

> ### NOTE
>
> Verify the version of the runner, the download instructions are in the wizard
>

To run the runner, from the **/bin** directory, open an administrator PowerShell console and type the instruction copied from the wizard, i.e.:

```powershell
.\start.ps1 -accountUuid '{xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxx}' -repositoryUuid '{xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxx}' -runnerUuid '{xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxx}' -OAuthClientId xxxxxxxxxxxxxxx -OAuthClientSecret xxxxxxxxxxxxxxxxxx -workingDirectory '..\temp'
```

## Installing the Runner as a Service in Windows

> [set-up runner as a service in windows](https://confluence.atlassian.com/bbkb/bitbucket-cloud-pipelines-set-up-runners-for-windows-as-a-windows-service-1223821219.html)

Microsoft provides an option called Windows Service to enable background tasks and long-running applications to run continuously and independently of user interaction. These services are designed to start automatically when the operating system boots up and run in the background without any user interface.

The runner's script is not packaged to run as a Windows service, but there are third-party solutions available to run the runner's launch script as a Windows OS service.

A third-party [WinSW](https://github.com/winsw/winsw) wrapper can be used to run the runner as a Windows service, which ensures that logging off will not have any impact on the runner's status. One can download the wrapper from the repository.

Detailed steps to set up the runners as Windows Service using WinSW.exe wrapper

From the folder that contains this readme, copy the ws-runner.exe and ws-runner.xml files to the runner folder, ex:

```powershell
# copy the service installer and configuration file to the runner directory
Copy-Item -Path .\ws-runner.exe -Destination path_to\bitbucket-pipelines-runner
Copy-Item -Path .\ws-runner.xml -Destination path_to\bitbucket-pipelines-runner

```

alternatively:

1. Download the WinSW.exe wrapper from the [WinSW](https://github.com/winsw/winsw) repository to the runner folder and rename it as ws-runner.exe
2. Create a configuration file by saving the content of the XML file as ws-runner.xml

Update the ws-runner.xml file, specifying

- id
- name
- description

and the arguments connection arguments copied from the `start.ps1` line

> Note:
>
> Make sure to note down the following variable values while creating the new runner:
>
> Dbitbucket.pipelines.runner.account.uuid
> Dbitbucket.pipelines.runner.repository.uuid
> Dbitbucket.pipelines.runner.uuid
> Dbitbucket.pipelines.runner.oauth.client.id
> Dbitbucket.pipelines.runner.oauth.client.secret
> The above arguments are required for repository-based runners. In the case of a workspace based runner, the "Dbitbucket.pipelines.runner.repository.uuid" argument is not required; you would only pass the following.
>
> Dbitbucket.pipelines.runner.account.uuid
> Dbitbucket.pipelines.runner.uuid
> Dbitbucket.pipelines.runner.oauth.client.id
> Dbitbucket.pipelines.runner.oauth.client.secret

Example:

```xml
<service>  
      <id>BitbucketRunnerService</id> 
      <name>Bitbucket Runner Service</name>  
      <description>Wrapper for JAVA based Bitbucket Runner</description>
      <executable>java</executable>
      <arguments>-jar -Dbitbucket.pipelines.runner.account.uuid={xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxx} -Dbitbucket.pipelines.runner.repository.uuid={xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxx} -Dbitbucket.pipelines.runner.uuid={xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxx} -Dbitbucket.pipelines.runner.environment=PRODUCTION -Dbitbucket.pipelines.runner.oauth.client.id=xxxxxxxxxxxxxx -Dbitbucket.pipelines.runner.oauth.client.secret=xxxxxxxxxxxxxx -Dbitbucket.pipelines.runner.directory.working=..\temp -Dbitbucket.pipelines.runner.runtime=windows-powershell -Dbitbucket.pipelines.runner.scheduled.state.update.initial.delay.seconds=0 -Dbitbucket.pipelines.runner.scheduled.state.update.period.seconds=30 -Dbitbucket.pipelines.runner.cleanup.previous.folders=false -Dfile.encoding=UTF-8 -Dsun.jnu.encoding=UTF-8 ./bin/runner.jar</arguments>  
    <log mode="roll"></log>  
    <logpath>%BASE%\logs</logpath>  
    <stopparentprocessfirst>true</stopparentprocessfirst>
</service> 
```

From the runner path install the service, ex:

```powershell
cd path_to\bitbucket-pipelines-runner

# Install the runner as a service
.\ws-runner.exe install ws-runner.xml 
```

Open the **Services** Window and start the service.
