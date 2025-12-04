#include <bits/stdc++.h>
using namespace std;

int main (int argc, char *argv[]) {
  ios::sync_with_stdio(false);
  cin.tie(nullptr);

  ifstream fin("input.txt");
  if (!fin) {
    cerr << "Error, file shit\n";
    return 1;
  }


  vector<string> grid;
  string line;
  while (getline(fin,line)) {
    if (!line.empty())
        grid.push_back(line);
  }

  int n = grid.size();
    int dx[8] = {-1,-1,-1, 0, 0, 1, 1, 1};
    int dy[8] = {-1, 0, 1,-1, 1,-1, 0, 1};

    int accessible = 0;

    for (int r = 0; r < n; ++r) {
        for (int c = 0; c < (int)grid[r].size(); ++c) {
            if (grid[r][c] != '@') continue;

            int adj = 0;
            for (int k = 0; k < 8; ++k) {
                int nr = r + dx[k], nc = c + dy[k];
                if (nr >= 0 && nr < n && nc >= 0 && nc < (int)grid[nr].size()) {
                    if (grid[nr][nc] == '@')
                        ++adj;
                }
            }

            if (adj < 4)
                ++accessible;
        }
    }

    cout << accessible << '\n';


  return 0;
}
