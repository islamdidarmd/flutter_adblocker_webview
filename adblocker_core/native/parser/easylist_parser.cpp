#include "easylist_parser.h"

EasyListParser::EasyListParser() {}

EasyListParser::~EasyListParser() {}

bool EasyListParser::loadFromFile(const std::string& filePath) {
    std::ifstream file(filePath);
    if (!file.is_open()) return false;
    
    std::string line;
    while (std::getline(file, line)) {
        if (!isComment(line)) {
            parseLine(line);
        }
    }
    
    return true;
}

bool EasyListParser::isComment(const std::string& line) const {
    return line.empty() || line[0] == '!' || line[0] == '[';
}

void EasyListParser::parseLine(const std::string& line) {
    // Handle element hiding rules (##)
    if (line.find("##") != std::string::npos) {
        parseElementHidingRule(line);
        return;
    }
    
    // Handle domain blocking rules
    if (line[0] != '#' && line[0] != '@') {
        std::string domain = line;
        size_t protocolPos = domain.find("://");
        if (protocolPos != std::string::npos) {
            domain = domain.substr(protocolPos + 3);
        }
        size_t pathPos = domain.find("/");
        if (pathPos != std::string::npos) {
            domain = domain.substr(0, pathPos);
        }
        if (!domain.empty()) {
            domainBlacklist.insert(domain);
        }
    }
}

void EasyListParser::parseElementHidingRule(const std::string& rule) {
    size_t separatorPos = rule.find("##");
    if (separatorPos == std::string::npos) return;
    
    // Get the selector part after ##
    std::string selector = rule.substr(separatorPos + 2);
    
    // Skip complex selectors with :has(), :not(), etc.
    if (selector.find(":") != std::string::npos) return;
    
    // Add selector if it contains common ad-related terms
    std::vector<std::string> adTerms = {
        "ad", "ads", "advert", "banner", "sponsor", "promo",
        "publicity", "commercial", "marketing", "tracking"
    };
    
    for (const auto& term : adTerms) {
        if (selector.find(term) != std::string::npos) {
            adSelectors.insert(selector);
            break;
        }
    }
}

bool EasyListParser::isUrlBlocked(const std::string& url) const {
    for (const auto& domain : domainBlacklist) {
        if (url.find(domain) != std::string::npos) {
            return true;
        }
    }
    return false;
}

std::string EasyListParser::getAdSelectors() const {
    std::string result;
    bool first = true;
    
    for (const auto& selector : adSelectors) {
        if (!first) {
            result += ", ";
        }
        result += selector;
        first = false;
    }
    
    return result;
}

std::vector<std::string> EasyListParser::getBlockedDomains() const {
    // Convert unordered_set to vector for return
    return std::vector<std::string>(domainBlacklist.begin(), domainBlacklist.end());
}