<%@ page
  contentType="text/html; charset=UTF-8"
  import="javax.servlet.http.*"
  import="java.io.*"
  import="java.util.*"
  import="org.apache.hadoop.mapred.*"
  import="org.apache.hadoop.fs.*"
  import="org.apache.hadoop.util.*"
  import="java.text.SimpleDateFormat"
  import="org.apache.hadoop.mapred.JobHistory.*"
%>

<%!	
  private static SimpleDateFormat dateFormat =
                                    new SimpleDateFormat("d/MM HH:mm:ss") ; 
%>
<%!	private static final long serialVersionUID = 1L;
%>

<%	
  String jobid = request.getParameter("jobid");
  String logFile = request.getParameter("logFile");
  String encodedLogFileName = JobHistory.JobInfo.encodeJobHistoryFilePath(logFile);
  String taskStatus = request.getParameter("status"); 
  String taskType = request.getParameter("taskType"); 
  
  FileSystem fs = (FileSystem) application.getAttribute("fileSys");
  JobHistory.JobInfo job = JSPUtil.getJobInfo(request, fs);
  Map<String, JobHistory.Task> tasks = job.getAllTasks(); 
%>
<html>
<head>
  <title><%=taskStatus%> <%=taskType %> task list for <%=jobid %></title>
  <link rel="stylesheet" type="text/css" href="/static/hadoop.css">
  <link rel="icon" type="image/vnd.microsoft.icon" href="/static/images/favicon.ico" />
</head>
<body>
<h2><%=taskStatus%> <%=taskType %> task list for <a href="jobdetailshistory.jsp?jobid=<%=jobid%>&&logFile=<%=encodedLogFileName%>"><%=jobid %> </a></h2>
<center>
<table class="jobtasks datatable">
<thead>
<tr><th>Task Id</th><th>Start Time</th><th>Finish Time<br/></th><th>Error</th></tr>
</thead>
<tbody>
<%
  for (JobHistory.Task task : tasks.values()) {
    if (taskType.equals(task.get(Keys.TASK_TYPE))){
      Map <String, TaskAttempt> taskAttempts = task.getTaskAttempts();
      for (JobHistory.TaskAttempt taskAttempt : taskAttempts.values()) {
        if (taskStatus.equals(taskAttempt.get(Keys.TASK_STATUS)) || 
          taskStatus.equals("all")){
          printTask(jobid, encodedLogFileName, taskAttempt, out); 
        }
      }
    }
  }
%>
</tbody>
</table>
<%!
  private void printTask(String jobid, String logFile,
    JobHistory.TaskAttempt attempt, JspWriter out) throws IOException{
    out.print("<tr>"); 
    out.print("<td>" + "<a href=\"taskdetailshistory.jsp?jobid=" + jobid + 
          "&logFile="+ logFile +"&taskid="+attempt.get(Keys.TASKID)+"\">" +
          attempt.get(Keys.TASKID) + "</a></td>");
    out.print("<td>" + StringUtils.getFormattedTimeWithDiff(dateFormat, 
          attempt.getLong(Keys.START_TIME), 0 ) + "</td>");
    out.print("<td>" + StringUtils.getFormattedTimeWithDiff(dateFormat, 
          attempt.getLong(Keys.FINISH_TIME),
          attempt.getLong(Keys.START_TIME) ) + "</td>");
    out.print("<td>" + attempt.get(Keys.ERROR) + "</td>");
    out.print("</tr>"); 
  }
%>
</center>
</body>
</html>
