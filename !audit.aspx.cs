using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data.SqlClient;
using System.Configuration;
using System.Data;
using AjaxControlToolkit;

public partial class ConsumerDatabase_audit : System.Web.UI.Page
{
//    SqlConnection con = new SqlConnection(ConfigurationManager.ConnectionStrings["supportConnectionString"].ConnectionString);
    protected void Page_Load(object sender, EventArgs e)
    {
        TreeView thetreeview = (TreeView)Master.FindControl("TreeView1");
        thetreeview.DataSourceID = "proglevel";
        BindListViewControls();
        HttpCookie cookie = Request.Cookies["pAuthCookie"];
        if (cookie == null)
            Response.Redirect("~/LogOn.aspx");
        int getaccess; getaccess = security.determine_access("hepclass");

    }
    public void search(object sender, EventArgs e)
    {
        string heritageID = txtSearch.Text.ToString().Trim();
        string tableName = ddlTable.SelectedItem.Text.ToString().Trim();
        string recordID = txtRecordID.Text.ToString().Trim();
        string searchDate = misc_class.format_mmddyyyy(txtDate.Text).Trim();
        //Passing the above parameters to the next method
        ListView1.DataSource = GetAuditActs(heritageID, searchDate, tableName, recordID);
        ListView1.DataBind();
     }
    private DataTable GetAuditActs(string id, string searchDate, string tableName, string record)
    {
        //separating Data Access code from user interface code, and making sure that connection and command are closed after usage. The following method doesn’t know anything about UI.
        string connectionString = ConfigurationManager.ConnectionStrings["AuditConnectionString"].ConnectionString;
        using (var conn = new SqlConnection(connectionString))
        using (var cmd = AuditSelectCommand(id, searchDate, tableName, record))
        {
            cmd.Connection = conn;
            conn.Open();
            SqlDataAdapter adapter = new SqlDataAdapter(cmd);
            DataTable table = new DataTable();
            adapter.Fill(table);
            return table;
        }
    }
    private SqlCommand AuditSelectCommand(string id, string searchDate, string tableName, string record)
    {
        //This method creates the SELECT command
        var cmd = new SqlCommand();
        List<string> filters = new List<string>();

        if (!String.IsNullOrEmpty(id))
        {
            filters.Add("([old] = @ID OR [new] = @ID)");
            cmd.Parameters.AddWithValue("@ID", id);
        }

        if (!String.IsNullOrEmpty(record))
        {
            filters.Add("[tablefk] = @Record");
            cmd.Parameters.AddWithValue("@Record", record);
        }

        if (!String.IsNullOrEmpty(searchDate))
        {
            filters.Add("CONVERT(date,[entrytime]) = @Date");
            cmd.Parameters.AddWithValue("@Date", searchDate);
        }

        if (!String.IsNullOrEmpty(tableName))
        {
            filters.Add("[tablename] = @TableName");
            cmd.Parameters.AddWithValue("@TableName", tableName);
        }

        string whereClause = filters.Any() ? "WHERE " + String.Join(" AND ", filters) : "";
        string count = filters.Any() ? "" : "TOP 100";

        var query = String.Format(
                @"SELECT {0} [auditpk],[databaseName],[tableName],[tablefk],[fieldname],[old],[new],[userfk],[action],[entrytime],[username] FROM AUDITACT {1} ORDER BY entrytime DESC", count, whereClause);
        cmd.CommandText = query;
        return cmd;
    }
    private void BindListViewControls()
    {
        string connectionString = ConfigurationManager.ConnectionStrings["AuditConnectionString"].ConnectionString;
        string query = "SELECT top 5 [auditpk],[databaseName],[tableName],[tablefk],[fieldname],[old],[new],[userfk],[action],[entrytime],[username] FROM AUDITACT where entrytime >= CONVERT(DATE,DATEADD(DAY,-5,GETDATE())) and [tableName] = 'CONTACTS' order by [entrytime] desc";

        SqlDataAdapter da = new SqlDataAdapter(query, connectionString);
        DataTable table = new DataTable();
        da.Fill(table);

        ListView1.DataSource = table;
        ListView1.DataBind();
    }
    public void clear(object sender, EventArgs e)
    {
        txtSearch.Text = "";
        ddlTable.SelectedIndex = 0;
        txtDate.Text = "";
        txtRecordID.Text = "";
    }

}
