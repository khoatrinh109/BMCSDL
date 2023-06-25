using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Login
{
    class ConnectSQL
    {
        string con;
        public ConnectSQL()
        {
            con = @"Data Source=DESKTOP-S75JGSP;Initial Catalog=QLSV_Lab4;Integrated Security=True";

        }
        public SqlConnection getConnect()
        {
            return new SqlConnection(con);
        }
    }
}
