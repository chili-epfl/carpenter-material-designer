#include "exporter.h"
#include "global.h"
#include <QFile>
#include <QDateTime>
#include <QTextStream>
#include <QUrl>
#include <QImage>
#include <quazip/JlCompress.h>
#include <QDebug>
#include <QNetworkRequest>
#include <QNetworkReply>
#include <QDirIterator>

Exporter::Exporter(QObject *parent) : QObject(parent)
{
    m_loading=false;
    connect(this,SIGNAL(pushCompleted()),this,SLOT(finished()));
}

void Exporter::createFile(QUrl imageUrl, QString name, QString density, QString price, QString Young, QString G)
{
    if(m_host.isEmpty() || m_username.isEmpty()) return;
    if(name.isEmpty() ||  density.isEmpty() || price.isEmpty() || Young.isEmpty() || G.isEmpty()){
        emit error("All fields should be filled");
        return;
    }
    if(density.toDouble()<0.1 || density.toDouble()>2){
        emit error("Desity-rangeError");
        return;
    }
    if(price.toInt()<1 || price.toInt()>100){
        emit error("Price-rangeError");
        return;
    }
    if(Young.toInt()<15000 || Young.toInt()>30000){
        emit error("Elasticity-rangeError");
        return;
    }
    if(G.toInt()<1000 || G.toInt()>1500){
        emit error("ShearModule-rangeError");
        return;
    }


    QString filename=QDateTime::currentDateTime().toString("dMyyhms");
    QFile file(tmpDir+m_username+"-"+filename+".material");
    file.open(QFile::WriteOnly);
    QImage image(imageUrl.toLocalFile());

    if(file.isOpen() && !image.isNull()){
        QTextStream out(&file);
        out<< "UniqueID:"<<m_username+"-"+filename<<";\n"
           <<"Name:"<<name<<";\n"
          <<"Density:"<<density<<"e-9"<<";\n"
         <<"Price:"<<price<<";\n"
        <<"Young:"<<Young<<";\n"
        <<"G:"<<G<<";\n"
        <<"TextureImage:"<<m_username+"-"+filename<<".png;";
        file.close();
        image.save(tmpDir+m_username+"-"+filename+".png");
        JlCompress::compressDir(materialsDir+m_username+"-"+filename+".static_material",tmpDir);
        image.save(materialsDir+m_username+"-"+filename+".png");
        file.remove();
        QFile::remove(tmpDir+m_username+"-"+filename+".png");
    }
    else{
        emit error("Can't create file or read image");
    }

}

void Exporter::setHost(QString host)
{
    if(host!=m_host){
        m_host=host;
        emit hostChanged();
    }

}

void Exporter::setUsername(QString username)
{
    if(username!=m_username){
        m_username=username;
        emit usernameChanged();
    }
}


void Exporter::pushMaterials(){
    m_loading=true;
    emit loadingChanged();

    QDir materialsPath(materialsDir);
    QStringList files=materialsPath.entryList();
    Q_FOREACH(QString file, files){
        if(!file.endsWith(".static_material")) continue;
        QString basename=file.split(".static_material")[0];
        if(!files.contains(basename+".png")) continue;
        QNetworkRequest push;
        QUrl url=m_host;
        QString query="type=request-put&resourceType=material&email="+m_username
                +"&filename="+file+"&thumbnail="+basename+".png";
        url.setQuery(query);
        push.setUrl(url);
        PushData pushData;
        pushData.filename=file;
        pushData.thumbnail=basename+".png";
        pushData.replies_S3=0;

        QNetworkReply* reply=manager.get(push);
        connect(reply, SIGNAL(finished()), this, SLOT(slotPushPhase1()));
        connect(reply, SIGNAL(error(QNetworkReply::NetworkError)),
                this, SLOT(slotError()));
        m_pushData_map[reply]=pushData;
    }
    if(m_pushData_map.count()==0)
        emit pushCompleted();
}

void Exporter::slotPushPhase1(){
    QNetworkReply *reply=static_cast<QNetworkReply *>(QObject::sender());
    if(reply->error()==QNetworkReply::NoError){
        QString urlFile, urlThumbnail;
        urlFile=reply->readLine();
        urlFile=urlFile.split("\r\n")[0];

        urlThumbnail=reply->readLine();
        urlThumbnail=urlThumbnail.split("\r\n")[0];

        QNetworkRequest putFile;
        QUrl URLFile=urlFile;
        putFile.setUrl(URLFile);
        QFile* file=new QFile(materialsDir+m_pushData_map[reply].filename);
        file->open(QIODevice::ReadOnly);
        if(!file->isOpen()){
            emit error("Can't open file "+materialsDir+m_pushData_map[reply].filename);
        }else{
            QNetworkReply *replyFile = manager.put(putFile,file);
            connect(replyFile, SIGNAL(finished()), this, SLOT(slotCloseFile()));
            connect(replyFile, SIGNAL(error(QNetworkReply::NetworkError)),
                    this, SLOT(slotError()));
            m_openFile_map[replyFile]=file;


            QNetworkRequest putThumbnail;
            QUrl URLThumbnail=urlThumbnail;
            putThumbnail.setUrl(URLThumbnail);
            QFile* thumbnailFile=new QFile(materialsDir+m_pushData_map[reply].thumbnail);
            thumbnailFile->open(QIODevice::ReadOnly);
            if(!thumbnailFile->isOpen()){
                emit error("Can't open thumbnail "+materialsDir+m_pushData_map[reply].thumbnail);
            }else{
                QNetworkReply *replyThumbnail = manager.put(putThumbnail,thumbnailFile);
                connect(replyThumbnail, SIGNAL(finished()), this, SLOT(slotCloseFile()));
                connect(replyThumbnail, SIGNAL(finished()), this, SLOT(slotThumbnailUploaded()));
                connect(replyThumbnail, SIGNAL(error(QNetworkReply::NetworkError)),
                        this, SLOT(slotError()));
                m_openFile_map[replyThumbnail]=thumbnailFile;
                m_pushData_map[replyThumbnail]=m_pushData_map[reply];
            }}}

    m_pushData_map.remove(reply);
    reply->deleteLater();
    if(m_pushData_map.count()==0){
        emit pushCompleted();
    }
}
void Exporter::slotPushPhase2(){
    QNetworkReply *reply=static_cast<QNetworkReply *>(QObject::sender());
    m_pushData_map.remove(reply);
    reply->deleteLater();
    if(m_pushData_map.count()==0){
        emit pushCompleted();
    }
}
void Exporter::slotThumbnailUploaded(){
    QNetworkReply *reply=static_cast<QNetworkReply *>(QObject::sender());
    if(reply->error()==QNetworkReply::NoError){
        /*Create the Post*/
        QNetworkRequest createPost;
        QUrl createPostURL=m_host;

        QString resourceType="resourceType=material";

        QString email="email="+m_username;

        QString filename="filename="+m_pushData_map[reply].filename;
        QString thumbnail="thumbnail="+m_pushData_map[reply].thumbnail;

        QString query=QString("type=create-post&")+email+"&"+resourceType+"&"+filename
                +"&"+thumbnail;
        createPostURL.setQuery(query);
        createPost.setUrl(createPostURL);
        QNetworkReply *postReply = manager.get(createPost);
        connect(postReply, SIGNAL(finished()), this, SLOT(slotPushPhase2()));
        connect(postReply, SIGNAL(error(QNetworkReply::NetworkError)),
                this, SLOT(slotError()));
        m_pushData_map[postReply]=m_pushData_map[reply];
    }
    m_pushData_map.remove(reply);
    reply->deleteLater();
    if(m_pushData_map.count()==0){
        emit pushCompleted();
    }
}
void Exporter::slotCloseFile(){
    QNetworkReply *reply=static_cast<QNetworkReply *>(QObject::sender());
    if(m_openFile_map.contains(reply)){
        QFile* f=m_openFile_map[reply];
        m_openFile_map.remove(reply);
        f->close();
        f->copy(uploadedDir+f->fileName());
        f->remove();
        f->deleteLater();
    }
    reply->deleteLater();
}

void Exporter::slotError(){
    QNetworkReply *reply=static_cast<QNetworkReply *>(QObject::sender());
    qDebug()<<reply->error();
    if(m_openFile_map.contains(reply)){
        QFile* f=m_openFile_map[reply];
        m_openFile_map.remove(reply);
        f->close();
        f->deleteLater();
    }
    m_pushData_map.remove(reply);
    reply->deleteLater();
    if(m_pushData_map.count()==0){
        emit pushCompleted();
    }
    emit error(reply->errorString());
}

void Exporter::finished()
{
    m_loading=false;
    emit loadingChanged();
}
