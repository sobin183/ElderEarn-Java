<%@ page import="java.sql.*" %>
<%@ page import="com.elderearn.database.DBConnection" %>

<!DOCTYPE html>

<html>
<head>

<meta charset="UTF-8">
<title>Available Skills</title>

<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">

<style>

body{
    background:#f2f2f2;
}

.card{
    border-radius:10px;
}

</style>

</head>

<body>

<div class="container mt-5">

```
<h2 class="text-center mb-4">
    Available Skills
</h2>

<div class="row">
```

<%
try{


Connection conn = DBConnection.getConnection();

String sql = "SELECT * FROM skills";

PreparedStatement ps =
        conn.prepareStatement(sql);

ResultSet rs = ps.executeQuery();

while(rs.next()){


%>

```
    <div class="col-md-4 mb-4">

        <div class="card shadow">

            <div class="card-body">

                <h4>
                    <%= rs.getString("skill_title") %>
                </h4>

                <p>
                    <strong>Teacher:</strong>
                    <%= rs.getString("teacher_name") %>
                </p>

                <p>
                    <strong>Category:</strong>
                    <%= rs.getString("category") %>
                </p>

                <p>
                    <%= rs.getString("description") %>
                </p>

                <h5 class="text-success">
                    Rs. <%= rs.getString("price") %>
                </h5>

                <button class="btn btn-primary w-100">
                    Subscribe
                </button>

            </div>

        </div>

    </div>
```

<%
}

}
catch(Exception e){


out.println("<h3>Error : " + e.getMessage() + "</h3>");


}
%>

```
</div>
```

</div>

</body>
</html>
