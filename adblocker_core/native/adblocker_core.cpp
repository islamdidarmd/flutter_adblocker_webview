#include "adblocker_core.h"
#include <cstring>

EasyListParser* easy_list_create_parser() {
    return new EasyListParser();
}

void easy_list_destroy_parser(EasyListParser* parser) {
    if (parser) {
        delete parser;
    }
}

bool easy_list_load_from_file(EasyListParser* parser, const char* file_path) {
    if (!parser || !file_path) return false;
    return parser->loadFromFile(file_path);
}

bool easy_list_is_url_blocked(EasyListParser* parser, const char* url) {
    if (!parser || !url) return false;
    return parser->isUrlBlocked(url);
}

char* easy_list_get_ad_selectors(EasyListParser* parser) {
    if (!parser) return nullptr;
    
    std::string selectors = parser->getAdSelectors();
    char* result = new char[selectors.length() + 1];
    strcpy(result, selectors.c_str());
    return result;
}

void easy_list_free_string(char* str) {
    if (str) {
        delete[] str;
    }
}

StringArray easy_list_get_blocked_domains(EasyListParser* parser) {
    StringArray result = {nullptr, 0};
    
    if (!parser) return result;
    
    std::vector<std::string> domains = parser->getBlockedDomains();
    result.length = domains.size();
    result.data = new char*[domains.size()];
    
    for (size_t i = 0; i < domains.size(); i++) {
        result.data[i] = new char[domains[i].length() + 1];
        strcpy(result.data[i], domains[i].c_str());
    }
    
    return result;
}

void easy_list_free_string_array(StringArray array) {
    if (array.data) {
        for (size_t i = 0; i < array.length; i++) {
            delete[] array.data[i];
        }
        delete[] array.data;
    }
}