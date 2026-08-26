# 🇮🇹 Italian Vocabulary — iOS

Kendi İtalyanca öğrenme sürecim için geliştirdiğim, **SwiftUI, Supabase, WidgetKit ve Swift Charts** tabanlı iOS kelime öğrenme uygulaması.

Uygulama; kelimeleri bölümler halinde çalışmayı, aktif hatırlama quizleri çözmeyi, öğrenme ilerlemesini ve hataları takip etmeyi, geçmiş çalışma verilerini analiz etmeyi ve Lock Screen widget ile gün içinde kelimelerle karşılaşmaya devam etmeyi sağlıyor.

Bu proje, daha önce geliştirdiğim **Python tabanlı İtalyanca Kelime Quiz ve Öğrenme Analiz Sistemi'nin iOS tarafıdır.**

---

## Projenin çıkış noktası

İtalyanca öğrenirken temel hedefim kelimeleri yalnızca tanımak değil, **konuşurken ihtiyaç duyduğum anda hatırlayabilmek**.

Bu nedenle hazır kelime listeleri yerine; videolarda, günlük konuşmalarda, seyahat sırasında veya kendi hayatımda kullanmak istediğim kelime ve ifadelerden oluşan kişisel bir veri seti kullanıyorum.

Kelime listemi CSV üzerinde geliştirmeye devam ederken iOS uygulaması bu sistemi günlük kullanım için daha erişilebilir hale getiriyor.

---

## Ekran Görüntüleri

### Ana Sayfa ve Kelime Çalışma

<p align="center">
<img src="docs/images/1.png" width="250">
<img src="docs/images/2.png" width="250">
</p>

### Quiz

<p align="leading">
<img src="docs/images/3.png" width="250">
</p>

### İlerleme ve Geçmiş

<p align="center">
<img src="docs/images/4.png" width="250">
<img src="docs/images/5.png" width="250">
</p>

### Lock Screen Widget

<p align="center">
<img src="docs/images/6.png" width="250">
<img src="docs/images/7.png" width="250">
</p>

---

## Özellikler

###  Bölüm bazlı kelime çalışma

Kelime listesi tek seferde gösterilmek yerine daha küçük çalışma bölümlerine ayrılıyor.

Uygulama:

- yeni kelimeleri bölümler halinde sunar,
- her bölümün ilerlemesini takip eder,
- öğrenilmiş ve tekrar edilmesi gereken kelimeleri ayırır,
- tamamlanan quiz sonrasında ilgili bölüme hızlı dönüş sağlar.

###  Aktif hatırlama quiz sistemi

Quiz sisteminde çoktan seçmeli cevaplar yerine İtalyanca kelimenin doğrudan yazılması gerekiyor.

Bu sayede kelimeyi görmek ve tanımak yerine, konuşma sırasında gerektiği gibi **hafızadan geri çağırma** pratiği yapılmış oluyor.

Yanlış cevaplar daha sonra tekrar çalışılabilmesi için kaydediliyor ve farklı hata türlerine göre sınıflandırılıyor.

###  İlerleme ve öğrenme analizi

Progress ekranında:

- öğrenme ilerlemesi,
- doğruluk oranları,
- zorlanılan kelimeler,
- hata türleri,
- bölüm ilerlemeleri

takip edilebiliyor.

Amaç yalnızca kaç kelime çalışıldığını göstermek değil, **sonraki çalışmada hangi kelimelere odaklanılması gerektiğini** anlamak.

###  Çalışma geçmişi

Quiz geçmişi Supabase üzerinde saklanıyor ve uygulama içerisinde incelenebiliyor.

**Swift Charts** kullanılarak son 30 günlük çalışma aktivitesi görselleştiriliyor.

Grafikte günlük olarak:

- görülen kelime sayısı,
- doğru cevaplanan kelime sayısı

takip edilebiliyor.

Uzun vadede büyüyecek geçmiş verileri için pagination ve tarih filtreleme kullanılıyor.

---

##  Lock Screen Widget

WidgetKit kullanılarak geliştirilen Lock Screen widget, gün boyunca İtalyanca kelimelerle karşılaşmaya devam etmeyi sağlıyor.

Widget:

- İtalyanca kelimeyi,
- kelimenin İtalyanca açıklamasını

kilit ekranında gösteriyor.

Kelime her uygulama açılışında değişmek yerine yaklaşık **3 saatlik bir rotasyon** kullanıyor.

Ana uygulama yaklaşan kelimeleri hazırlıyor ve **App Group** üzerinden widget ile paylaşıyor. Böylece uygulama açık olmasa bile WidgetKit kendi timeline'ı üzerinden kelimeleri değiştirebiliyor.

```text
Supabase
↓
iOS Uygulaması
↓
App Group Cache
↓
WidgetKit Timeline
↓
Lock Screen
```

### Widget → Kelime Detayı

Widget üzerindeki kelimeye dokunulduğunda deep link kullanılarak uygulama doğrudan ilgili kelimenin detay ekranında açılıyor.

Burada:

- İtalyanca kelime,
- Türkçe anlam,
- İngilizce anlam,
- İtalyanca açıklama,
- örnek İtalyanca cümle

görülebiliyor.

---

## Python projesiyle bağlantısı

Bu uygulama, daha önce geliştirdiğim Python tabanlı İtalyanca çalışma sisteminin devamı niteliğinde.

Python tarafında:

- kişisel kelime veri setini CSV üzerinde tutuyorum,
- terminal tabanlı quizler çalıştırabiliyorum,
- çalışma sonuçlarını ve hata türlerini analiz edebiliyorum,
- yeni kelimeleri Supabase'e senkronize edebiliyorum.

Yeni kelimeleri CSV'ye ekledikten sonra:

```bash
python sync_words.py
```

komutuyla yalnızca yeni eklenen kelimeler Supabase'e aktarılıyor.

iOS uygulaması ise aynı verileri mobil tarafta kullanarak günlük çalışma deneyimini oluşturuyor.

```text
Italyanca_Kelimeler.csv
↓
sync_words.py
↓
Supabase
↓
    Mobil Uygulamam
┌────────┴─────────┐
│                  │
Practice          Widget
Quiz             Word Detail
Progress
History
```

Böylece CSV tabanlı çalışma düzenimi değiştirmeden Python ve iOS projelerini aynı öğrenme sistemi içerisinde kullanabiliyorum.

---


*Melih Şişkular*
