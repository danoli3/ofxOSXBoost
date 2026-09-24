#include "ofApp.h"

#include <boost/filesystem.hpp>
#include <boost/version.hpp>

void ofApp::setup()
{
    const boost::filesystem::path path("ofxOSXBoost/example.txt");
    status_ = "Boost " + std::to_string(BOOST_VERSION) + " linked: " +
              path.filename().string();
    ofLogNotice("ofxOSXBoost") << status_;
}

void ofApp::draw()
{
    ofBackground(24);
    ofSetColor(240);
    ofDrawBitmapString(status_, 24, 40);
}
