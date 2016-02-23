#ifndef GLOBAL_H
#define GLOBAL_H
#include <QString>

#if ANDROID
const QString extstr=QString(getenv("EXTERNAL_STORAGE"))+"/carpenter-materials/";
const QString tmpDir(extstr+"tmp/");
const QString materialsDir(extstr+"materials/");
const QString uploadedDir(extstr+"uploaded/");
#else
const QString tmpDir("tmp/");
const QString materialsDir("materials/");
const QString uploadedDir("uploaded/");
#endif

#endif // GLOBAL_H
