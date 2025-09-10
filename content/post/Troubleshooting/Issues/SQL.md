
In the case that the service "MSSQLSERVER \ SQL Server (MSSQLSERVER)" is not starting after the snapshot rollback in VMware Workstation:

Review first these Event viewer IDs:

26024 - Server failed to listen on fe80::8145:ac41:7d9f:556%6 < ipv6 > 1433. Error: 0x2741. To proceed, notify your system administrator.

17182 - TDSSNIClient initialization failed with error 0x2741, status code 0xa. Reason: Unable to initialize the TCP/IP listener. The requested address is not valid in its context.

17182 - DSSNIClient initialization failed with error 0x2741, status code 0x1. Reason: Initialization failed with an infrastructure error. Check for previous errors. The requested address is not valid in its context.

17826 - Could not start the network library because of an internal error in the network library. To determine the cause, review the errors immediately preceding this one in the error log.

17120 - SQL Server could not spawn FRunCommunicationsManager thread. Check the SQL Server error log and the operating system error log for information about possible related problems.

![[Pasted image 20250831225843.png|1000]]

SQL Server is trying to bind to an IPv6 address that no longer exists:

**Fix**:

1) Disable the invalid IPv6 address:

Select IP1 (fe80::8145:ac41:7d9f:556%6)  
Set "Enabled" = No  
Keep IP2 (192.168.25.20) enabled

2) Click OK and Apply

3) Restart SQL Server:

net stop MSSQLSERVER  
net start MSSQLSERVER

![[Pasted image 20250831230828.png]]

