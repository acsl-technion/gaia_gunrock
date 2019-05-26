//#include <boost/interprocess/shared_memory_object.hpp>
//#include <boost/interprocess/mapped_region.hpp>
//#include <boost/interprocess/file_mapping.hpp>

#include <fstream>
#include <iostream>
#include <string>
#include <vector>
#include <sstream>
#include <cstddef>



//using namespace boost::interprocess;
using namespace std;


struct  Edge
{
    int from;//from vertex
    int to; //to vertex
    int val;
};

class myGraph
{
    private:
    vector <struct  Edge> edges;

    public:
    void add_adge(string line);
    void print(void);

};

/*
   I will give you a bit of work, make the funtions getdata() and dispdata()
   It's easy and not worth for me to bother with now :-}
*/
void myGraph::add_adge(string line) //get user input
{
	stringstream ss(line);
	string token;
	Edge edge;

	getline(ss, token, ' ');
	edge.from = stoi(token);

	getline(ss, token, ' ');
	edge.to = stoi(token);

	getline(ss, token, ' ');
	edge.val = stoi(token);

	edges.push_back(edge);
}

void myGraph::print(void)
{
	int sz = edges.size();
	for ( int i = 0; i < sz; i++ )
		cout << edges[i].from << " " << edges[i].to << " " << edges[i].val << endl;
}

const char *filename = "/home/tanya/gunrock/tests/my_test/road_usa.mtx";
const char *filename2 = "/home/tanya/gunrock/tests/my_test/road_usa.mtx2";
const char *bin_filename = "/home/tanya/gunrock/tests/my_test/test_mst.mtx.di.1.bin";

//This program is not tested, have fun fixing errors, if any
//I am a taos programmer so dont expect anything major
//Typing mistakes are not errors
//This was done off the cuff and not even compiled once
int main()
{
    fstream dataf ;  //file handle
    ofstream fout (filename2, ios::out);
    myGraph	g;

    dataf.open(filename,ios::in|ios::out);

    if(dataf.is_open()) {
    	cout << "File has been opened" << "\n";
    } else {
      cout << "ERROR, file " << filename << "can't be found" << endl;
      return 1;
    }

    string line;
    fout << line << endl;;
    cout << "first line of file " << line << endl << endl;

    while (getline(dataf, line)) {
    	//cout << line << endl;
	fout << line + " 3" << endl;;
    	//g.add_adge(line);
    }

    
    dataf.close();       //close the file
    fout.close();

    cout<<"\nEnd of Program" << endl;
    return 0;
}
