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
using sqlhelper;

public partial class HEP_prescriptions : System.Web.UI.Page
{
    SqlConnection con = new SqlConnection(ConfigurationManager.ConnectionStrings["supportConnectionString"].ConnectionString);
    HttpCookie cookie;
    bool isDelete = false;
    bool rowSelected;

    protected void Page_Load(object sender, EventArgs e)
    {
        TreeView thetreeview = (TreeView)Master.FindControl("TreeView1");
        thetreeview.DataSourceID = "heplevel";
        HttpCookie cookie = Request.Cookies["pAuthCookie"];
        if (cookie == null)
            Response.Redirect("~/LogOn.aspx");

        rowSelected = false;
        getSecurityAccess(rowSelected);
    }

    public enum Operation
    {
        NewRecord,
        Edit,
        Save,
        Revert,
        Delete
    }

    public SqlParameter[] GetParams()
    {
        cookie = Request.Cookies["pAuthCookie"];

        SqlParameter[] sqlParms = new SqlParameter[21];

        sqlParms[0] = new SqlParameter("@empfk", cookie["thenum"].ToString());
        sqlParms[1] = new SqlParameter("@prescriptpk", TxtKey.Text);
        sqlParms[2] = new SqlParameter("@date", misc_class.TryParse(TxtDate.Text));
        sqlParms[3] = new SqlParameter("@arcfk", DDLFullName.SelectedValue);
        sqlParms[4] = new SqlParameter("@OT", chkOT.Checked);
        sqlParms[5] = new SqlParameter("@PT", chkPT.Checked);
        sqlParms[6] = new SqlParameter("@PS", chkPS.Checked);
        sqlParms[7] = new SqlParameter("@SA", chkSA.Checked);
        sqlParms[8] = new SqlParameter("@EC", chkEC.Checked);
        sqlParms[9] = new SqlParameter("@NC", chkNC.Checked);
        String lReason = DDLReason.SelectedValue;
        if (String.Compare(lReason, "other", true) == 0)
        {
            lReason = txtOtherReason.Text;
            lReason = "Other-" + lReason;
            //30 is field length so to avoid crash...
            if (lReason.Length > 30)
                lReason = lReason.Substring(0, 30);
        }
        sqlParms[10] = new SqlParameter("@reason", lReason);
        sqlParms[11] = new SqlParameter("@sentto", TxtSentTo.Text);
        sqlParms[12] = new SqlParameter("@sentvia", DDLSentVia.SelectedValue);
        sqlParms[13] = new SqlParameter("@datereceived", misc_class.TryParse(TxtDateRec.Text));
        sqlParms[14] = new SqlParameter("@datesigned", misc_class.TryParse(txtDateSigned.Text));
        sqlParms[15] = new SqlParameter("@comments", txtComments.Text);
        sqlParms[16] = new SqlParameter("@effbeg", misc_class.TryParse(TxtEffBeg.Text));
        sqlParms[17] = new SqlParameter("@effend", misc_class.TryParse(TxtEffEnd.Text));
        sqlParms[18] = new SqlParameter("@documentation", txtDocumentation.Text);
        sqlParms[19] = new SqlParameter("@tablelock", cookie["email_user"].ToString().Trim() + cookie["thenum"].ToString().Trim());
        if (isDelete)    //if user hits Delete button
            sqlParms[20] = new SqlParameter("@Action", "DELETE");
        else
            sqlParms[20] = new SqlParameter("@Action", "INSERTorUPDATE");

            return sqlParms;
    }

    protected void AddSaveEditRevertClick(object sender, EventArgs e)
    {
        Button btn = (Button)sender;
        string ButtonText = btn.Text;

        switch (ButtonText)
        {
            case "Add":
                chooseOperation(Operation.NewRecord);
                break;
            case "Edit":
                chooseOperation(Operation.Edit);
                break;
            case "Save":
                chooseOperation(Operation.Save);
                break;
            case "Revert":
                chooseOperation(Operation.Revert);
                break;
            case "Delete":
                chooseOperation(Operation.Delete);
                break;
        }
    }

    protected void chooseOperation(Operation operation)
    {
        switch (operation)
        {
            case Operation.NewRecord:
                clearoutdata();
                BtnEdit.Enabled = true;
                InsertEditState();
                break;
            case Operation.Edit:
                InsertEditState();
                break;
            case Operation.Revert:
                DefaultState();
                break;
            case Operation.Save:
                SqlHelper.ExecuteNonQuery(con, CommandType.StoredProcedure, "prescriptions_InsertUpdateDelete", GetParams());
                DefaultState();
                break;
            case Operation.Delete:
                DeleteMode();
                DefaultState();
                break;
        }
        GridView1.DataBind();
    }

    protected void DeleteMode()
    {
        cookie = Request.Cookies["pAuthCookie"];
        if (string.IsNullOrEmpty(TxtKey.Text))
        {
            string scriptstring = "alert('User Error - Must Select From the LIST first.');";
            ScriptManager.RegisterStartupScript(TabGV, typeof(string), "alertscript", scriptstring, true);
            if (TabContainer1.ActiveTabIndex == 1)
                TabContainer1.ActiveTabIndex = 0;
            return;
        }
        else
        {
            //The actual deletion of the record
            isDelete = true;
            SqlHelper.ExecuteNonQuery(con, CommandType.StoredProcedure, "prescriptions_InsertUpdateDelete", GetParams());
        }
    }

    protected void RowSelected(object sender, EventArgs e)
    {
        GridViewRow gvrow = GridView1.SelectedRow;
        string pknum = GridView1.Rows[gvrow.RowIndex].Cells[10].Text;
        showpersoninfo(pknum);
        changecontrolstate(true);
        TabContainer1.ActiveTabIndex = 1;
        rowSelected = true;
        getSecurityAccess(rowSelected);
    }

    private void getSecurityAccess(bool rowSelected)
    {
        if (!rowSelected)  
        {
            string tlevel = security.get_RAED("prescriptions");
            if (tlevel.TrimEnd().Length != 0)
            {
                switch (tlevel)
                {
                    case "RAED":
                        {
                            BtnAdd.Enabled = true;
                            return;
                        }
                    case "RAE":
                        {
                            BtnAdd.Enabled = true;
                            return;
                        }
                    case "RE":
                        {
                            BtnAdd.Enabled = false;
                            BtnEdit.Enabled = false;
                            BtnDelete.Enabled = false;
                            return;
                        }
                    case "R":
                        {
                            BtnAdd.Enabled = false;
                            BtnEdit.Enabled = false;
                            BtnDelete.Enabled = false;
                            return;
                        }
                    case "N":
                        {
                            Response.Redirect("~/hep.aspx");
                            return;
                        }
                    default:
                        {
                            Response.Redirect("~/LogOn.aspx");
                            return;
                        }
                }
            }
            int getaccess; getaccess = security.determine_access("prescription");
            if (getaccess == 1)
            {
                BtnAdd.Enabled = true;
            }
        }
        else  //mode is outside of pageload, meaning they've selected a record/row at this point
        {
            string tlevel = security.get_RAED("prescriptions");
            if (tlevel.TrimEnd().Length != 0)
            {
                switch (tlevel)
                {
                    case "RAED":
                        {
                            BtnAdd.Enabled = true;
                            BtnEdit.Enabled = true;
                            BtnDelete.Enabled = true;
                            return;
                        }
                    case "RAE":
                        {
                            BtnAdd.Enabled = true;
                            BtnEdit.Enabled = true;
                            return;
                        }
                    case "RE":
                        {
                            BtnAdd.Enabled = false;
                            BtnEdit.Enabled = true;
                            BtnDelete.Enabled = false;
                            return;
                        }
                    case "R":
                        {
                            BtnAdd.Enabled = false;
                            BtnEdit.Enabled = false;
                            BtnDelete.Enabled = false;
                            return;
                        }
                    case "N":
                        {
                            Response.Redirect("~/hep.aspx");
                            return;
                        }
                    default:
                        {
                            Response.Redirect("~/LogOn.aspx");
                            return;
                        }
                }
            }
            int getaccess; getaccess = security.determine_access("prescription");
            if (getaccess == 1)
            {
                BtnDelete.Enabled = true;
                BtnEdit.Enabled = true;
            }
        }
    }

    private void DefaultState()
    {   
        //The default state a user should be in after a Save or Revert.
        changecontrolstate(true);
        TabContainer1.ActiveTabIndex = 0;
        BtnAdd.Text = "Add";
        BtnEdit.Text = "Edit";
        BtnEdit.Enabled = false;
        BtnDelete.Enabled = false;
        clearoutdata();
    }
    private void InsertEditState()
    {   
        //Any time a user is in INSERT or EDIT mode.
        changecontrolstate(false);
        TabContainer1.ActiveTabIndex = 1;
        BtnAdd.Text = "Save";
        BtnEdit.Text = "Revert";
        BtnDelete.Enabled = false;    
    }

    protected void showpersoninfo(string key)
    {
        using (var reader = SqlHelper.ExecuteReader(con, CommandType.Text, "Select * from prescriptions where prescriptpk = " + key))
        {
            while (reader.Read())
            {
                TxtKey.Text = reader["prescriptpk"].ToString();
                TxtDate.Text = reader["date"].ToString();
                String junk = reader["arcfk"].ToString();
                DDLFullName.SelectedValue = junk;
                DDLFullName.DataBind();
                chkOT.Checked = reader["OT"].ToString() == "True" ? true : false;
                chkPT.Checked = reader["PT"].ToString() == "True" ? true : false;
                chkPS.Checked = reader["PS"].ToString() == "True" ? true : false;
                chkSA.Checked = reader["SA"].ToString() == "True" ? true : false;
                chkEC.Checked = reader["EC"].ToString() == "True" ? true : false;
                chkNC.Checked = reader["NC"].ToString() == "True" ? true : false;
                //SATHI-ADDED CODE for Reason->Other drop down.
                junk = reader["reason"].ToString();
                if (junk.ToLower().StartsWith("other") == true)
                {
                    if (junk.ToLower().Contains("other-") == true)
                    {
                        String junk1;
                        String[] strSplit = junk.Split('-');
                        junk1 = strSplit[1];
                        junk = strSplit[0]; //expected to be "Other"
                        divOther.Visible = true;
                        txtOtherReason.Text = junk1;
                    }
                    else
                    {
                        //Other was there but reason was not found as part of it
                        divOther.Visible = true;
                        txtOtherReason.Text = "";
                    }
                }
                else
                {
                    divOther.Visible = false;
                    txtOtherReason.Text = "";
                }
                DDLReason.Text = junk;
                DDLReason.DataBind();
                //END of Sathi added code Reason->Other
                TxtSentTo.Text = reader["sentto"].ToString();
                DDLSentVia.SelectedValue = reader["sentvia"].ToString().TrimEnd();
                DDLSentVia.DataBind();
                TxtDateRec.Text = reader["datereceived"].ToString();
                txtDateSigned.Text = reader["dateSigned"].ToString();
                txtComments.Text = reader["comments"].ToString();
                TxtEffBeg.Text = reader["effbeg"].ToString();
                TxtEffEnd.Text = reader["effend"].ToString();
                txtDocumentation.Text = reader["documentation"].ToString();
            }
        }
    }

    protected void clearoutdata()
    {
        isDelete = false;
        TxtKey.Text = "";
        TxtDate.Text = "";
        DDLReason.SelectedIndex = 0;
        TxtEffBeg.Text = "";
        TxtEffEnd.Text = "";
        TxtSentTo.Text = "";
        DDLSentVia.SelectedIndex = 0;
        TxtDateRec.Text = "";
        txtDateSigned.Text = "";
        txtComments.Text = "";
        txtDocumentation.Text = "";
        chkOT.Checked = false;
        chkPT.Checked = false;
        chkPS.Checked = false;
        chkSA.Checked = false;
        chkEC.Checked = false;
        chkNC.Checked = false;
    }

    protected void changecontrolstate(Boolean tflag)
    {
        TabGV.Enabled = tflag;
        TreeView thetreeview = (TreeView)Master.FindControl("TreeView1");
        thetreeview.Enabled = tflag;
        TxtDate.ReadOnly = tflag;
        DDLFullName.Enabled = !tflag;
        TxtKey.ReadOnly = tflag;
        DDLReason.Enabled = !tflag;
        txtOtherReason.Enabled = !tflag;
        TxtEffBeg.ReadOnly = tflag;
        TxtEffEnd.ReadOnly = tflag;
        TxtSentTo.ReadOnly = tflag;
        DDLSentVia.Enabled = !tflag;
        TxtDateRec.ReadOnly = tflag;
        txtDateSigned.ReadOnly = tflag;
        txtComments.ReadOnly = tflag;
        txtDocumentation.ReadOnly = tflag;
        chkOT.Enabled = !tflag;
        chkPT.Enabled = !tflag;
        chkPS.Enabled = !tflag;
        chkSA.Enabled = !tflag;
        chkEC.Enabled = !tflag;
        chkNC.Enabled = !tflag;
        ImageButton1.Visible = !tflag;
        CalendarExtender1.Enabled = !tflag;
        ImageButton2.Visible = !tflag;
        CalendarExtender2.Enabled = !tflag;
        ImageButton3.Visible = !tflag;
        CalendarExtender3.Enabled = !tflag;
        ImageButton4.Visible = !tflag;
        CalendarExtender4.Enabled = !tflag;
        ImageButton5.Visible = !tflag;
        CalendarExtender5.Enabled = !tflag;
    }
    
    /// <summary>
    /// Handler for "Other" in "Reason for Rx" dropdown list
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void ReasonSelected(object sender, EventArgs e)
    {
        String strText = DDLReason.SelectedItem.Text;
        if (String.Compare(strText, "other", true) == 0)
        {
            divOther.Visible = true;

        }
        else
            divOther.Visible = false;
    }

    /// <summary>
    /// Handler for "Prescription Tracker" report button
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void Report1Click(object sender, EventArgs e)
    {

        string url = string.Empty;
        url = "~/reports/heprpt.aspx?val=presctracking";
        Response.Redirect(url, false);

    }
    protected void Report2Click(object sender, EventArgs e)
    {

        string url = string.Empty;
        url = "~/reports/heprpt.aspx?val=prescbasic";
        Response.Redirect(url, false);

    }
}
   

