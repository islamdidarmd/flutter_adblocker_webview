#ifndef EASYLIST_PARSER_H
#define EASYLIST_PARSER_H

#include <cstring>
#include <unordered_set>
#include <fstream>
#include <regex>
#include <vector>

class EasyListParser {
public:
    EasyListParser();
    ~EasyListParser();
    
    bool loadFromFile(const std::string& filePath);
    bool isUrlBlocked(const std::string& url) const;
    std::string getAdSelectors() const;
    std::vector<std::string> getBlockedDomains() const;
    
private:
    void parseLine(const std::string& line);
    bool isComment(const std::string& line) const;
    void parseElementHidingRule(const std::string& rule);
    
    std::unordered_set<std::string> domainBlacklist;
    std::unordered_set<std::string> adSelectors;
};

#endif // EASYLIST_PARSER_H