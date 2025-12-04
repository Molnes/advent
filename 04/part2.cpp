#include <bits/stdc++.h>
using namespace std;

int main() {
    ios::sync_with_stdio(false);
    cin.tie(nullptr);

    ifstream fin("input.txt");
    if (!fin) {
        cerr << "Error: file reading broke ahhhhhhh\n";
        return 1;
    }

    vector<string> grid;
    string line;
    while (getline(fin, line)) {
        if (!line.empty()) grid.push_back(line);
    }
    if (grid.empty()) {
        cout << 0 << '\n';
        return 0;
    }

    int n = grid.size();
    int dx[8] = {-1,-1,-1, 0, 0, 1, 1, 1};
    int dy[8] = {-1, 0, 1,-1, 1,-1, 0, 1};

    long long total_removed = 0;

    while (true) {
        vector<pair<int,int>> to_remove;
        for (int r = 0; r < n; ++r) {
            for (int c = 0; c < (int)grid[r].size(); ++c) {
                if (grid[r][c] != '@') continue;
                int adj = 0;
                for (int k = 0; k < 8; ++k) {
                    int nr = r + dx[k], nc = c + dy[k];
                    if (nr >= 0 && nr < n && nc >= 0 && nc < (int)grid[nr].size()) {
                        if (grid[nr][nc] == '@') ++adj;
                    }
                }
                if (adj < 4) to_remove.emplace_back(r, c);
            }
        }

        if (to_remove.empty()) break; // hate c++, break here since no more removes

        for (auto &p : to_remove) grid[p.first][p.second] = '.';
        total_removed += (int)to_remove.size();
    }

    cout << total_removed << '\n';
    return 0;
}
