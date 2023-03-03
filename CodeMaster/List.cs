using System;
using System.ComponentModel;
using System.Data;
using System.IO;
using System.Linq;
using System.Reflection.Emit;
using System.Windows.Forms;

namespace MasterForm
{
	public partial class List : Form
	{
		public List()
		{
			InitializeComponent();
			try
			{
				File.Delete("C:\\master-server\\temphwid.txt");
				File.Delete("C:\\master-server\\temp.csv");
			}
			catch
			{
			}
		}

		void List_Load(object sender, EventArgs e)
		{
			this.Text = " Admin panel \"Master\" | Slaves amount: " + Directory.GetDirectories("C:\\master-server\\public\\").Length + " | LEFT click Slave to control | RIGHT click Slave to delete | Click \'?\' to update grid -->";

			string CsvBase = "STATUS,Slave's Username + HWID,Last online,Date added"; //header of our virtual csv table file
			foreach(string s in Directory.GetDirectories("C:\\master-server\\public")) //create table of Slave PCs
			{
				//count time Slave last appeared online to tell Slave PC's online status
				string SlaveStatus = "❎OFFLINE";
				if ((DateTime.Now - Directory.GetLastWriteTime(s)).TotalSeconds < 30)
					SlaveStatus = "✅ONLINE";

				CsvBase += "\n" + SlaveStatus + "," + new DirectoryInfo(s).Name + "," + Directory.GetLastWriteTime(s) + "," + Directory.GetCreationTime(s);
			}

			try { File.Delete("C:\\master-server\\temp.csv"); } catch { }
			File.WriteAllText("C:\\master-server\\temp.csv", CsvBase);

			try
			{
				DataTable dt = new DataTable();

				File.ReadLines("C:\\master-server\\temp.csv").Take(1) // Creating the columns
					.SelectMany(x => x.Split(new[] { ',' }, StringSplitOptions.RemoveEmptyEntries))
					.ToList()
					.ForEach(x => dt.Columns.Add(x.Trim()));

				File.ReadLines("C:\\master-server\\temp.csv").Skip(1) // Adding the rows
					.Select(x => x.Split(','))
					.ToList()
					.ForEach(line => dt.Rows.Add(line));

				dataGridView1.DataSource = dt;
				dataGridView1.Sort(dataGridView1.Columns[2], ListSortDirection.Descending);
				dataGridView1.Rows[0].Selected = false; //unneeded auto selection fix
			}
			catch (Exception)
			{
				MessageBox.Show("Looks like you have no Slaves! Try running one on a PC, it should add into this list.", "Master", MessageBoxButtons.OK, MessageBoxIcon.Error);
			}
		}

		void Form1_FormClosed(object sender, FormClosedEventArgs e) //on window close
		{
			Environment.Exit(0);
		}

		void List_HelpButtonClicked(object sender, CancelEventArgs e) //on update "?" button clicked
		{
			List_Load("", e); // update list
		}

		void dataGridView1_CellMouseUp(object sender, DataGridViewCellMouseEventArgs e)
		{
            if (e.Button == MouseButtons.Left) //if left click - launch slave
            {
                try
                {
                    File.WriteAllText("C:\\master-server\\temphwid.txt", dataGridView1.Rows[e.RowIndex].Cells[1].Value.ToString());
                    this.Hide();
                    new Desk().ShowDialog(this);
                    this.Show();
                    List_Load("", e); // update list
                }
                catch (Exception)
                {
                    dataGridView1.Rows[0].Selected = false; //unneeded auto selection fix
                }
            }

            if (e.Button == MouseButtons.Right) //if right click - delete slave
            {
                DialogResult dialogResult = MessageBox.Show("Sure to delete this PC from list?\n(this will NOT ban it)", "   ❓   ", MessageBoxButtons.YesNo, MessageBoxIcon.Question);
                if (dialogResult == DialogResult.Yes)
                {
                    try
                    {
                        Directory.Delete("C:\\master-server\\public\\" + dataGridView1.Rows[e.RowIndex].Cells[1].Value.ToString(), true);
                    }
                    catch (Exception)
                    {
                        MessageBox.Show("Can't delete Slave's directory...\nDid something go wrong?", "Master", MessageBoxButtons.OK, MessageBoxIcon.Error);
                    }
                    List_Load("", e); // update list
                }
            }
        }
	}
}
