import 'package:flutter/material.dart';
import 'dart:math';

class Constants {
  static List<String> jamaatList = [
    'Tablighi Jamath',
    'Jamiyath-e-Ulmaye Hind',
    'Rabtay-e-Milath',
    'Dawoodo Allah ki Taraf',
    'MRF',
    'SIO',
    'Jamiyath Ahl-e-Hadees',
    'Safa Baitul Mall',
    'Jamiyath Ahl-e-Sunathul Jamath',
    'Rifah Chaimber of Commerce',
    'Al-Falah Trust',
    'Samjhota Committee',
    'SYM',
    'Shoeba-e-Islahe Mashera Jamate Islami Hind',
    'Helping Hand Society',
    'Moment of Justice',
    'youth of Bidar',
    'Bidar Betterment Foundation',
    "Other",
    'Shaheen Staff',
    'Shaheen Alumni',
    'BBF Staff',
    'Not Assosciated with any Jamaat',
    'Education Dept',
    'Shaheen Staff (Female)',
    'Madarsa Plus',
    'IMAM MASJID',
    'Trustee',
    'GIO',
    'shoeba-e-Khawateen jamat-e-islami hind',
    'AITA',
    'majlis-ul-maulimath tehreek-e-islami hind',
    'Shoeba-e-khawateen jamat-e-ahle hadees',
    'Sunni ( ladies )',
    'Tabligi ( ladies )',
  ];

  static const List<String> quotes = [
    "Quran 2:153: 'Indeed, Allah is with the patient.'",
    "Prophet Muhammad (PBUH): 'Patience is light.' (Sahih Muslim)",
    "Quran 39:10: 'Indeed, the patient will be given their reward without account.'",
    "Quran 16:127: 'And be patient, [O Muhammad], and your patience is not but through Allah.'",
    "Prophet Muhammad (PBUH): 'The real patience is at the first stroke of a calamity.' (Sahih Bukhari)",
    "Quran 70:5: 'So be patient with gracious patience.'",
    "Prophet Muhammad (PBUH): 'When Allah loves a servant, He tests him.' (Tirmidhi)",
    "Quran 11:11: 'Except for those who are patient and do righteous deeds.'",
    "Prophet Muhammad (PBUH): 'Whoever remains patient, Allah will make him patient.' (Sahih Bukhari)",
    "Quran 3:200: 'Persevere and endure and remain stationed and fear Allah that you may be successful.'",
    "Prophet Muhammad (PBUH): 'No one has been given a gift better and more comprehensive than patience.' (Sahih Bukhari)",
    "Quran 103:2-3: 'Indeed, mankind is in loss, Except for those who have believed and done righteous deeds and advised each other to truth and advised each other to patience.'",
    "Prophet Muhammad (PBUH): 'There is no Muslim who is afflicted with a calamity and says what Allah has enjoined, ‘To Allah we belong and to Him we will return; O Allah, reward me for my affliction and compensate me with something better,’ but Allah will compensate him with something better.' (Sahih Muslim)",
    "Quran 39:10: 'Say, O My servants who have believed, fear your Lord. For those who do good in this world is good, and the earth of Allah is spacious. Indeed, the patient will be given their reward without account.'",
    "Prophet Muhammad (PBUH): 'The strong man is not the one who is good at wrestling, but the strong man is the one who controls himself in a fit of rage.' (Sahih Bukhari)",
    "Prophet Muhammad (PBUH): 'How wonderful is the affair of the believer, for his affairs are all good, and this applies to no one but the believer. If something good happens to him, he is thankful for it and that is good for him. If something bad happens to him, he bears it with patience and that is good for him.' (Sahih Muslim)",
    "Quran 16:126: 'And if you punish [an enemy, O believers], punish with an equivalent of that with which you were harmed. But if you are patient - it is better for those who are patient.'",
    "Prophet Muhammad (PBUH): 'No fatigue, nor disease, nor sorrow, nor sadness, nor hurt, nor distress befalls a Muslim, even if it were the prick he receives from a thorn, but that Allah expiates some of his sins for that.' (Sahih Bukhari)",
    "Quran 2:45: 'And seek help through patience and prayer, and indeed, it is difficult except for the humbly submissive [to Allah].'",
    "Quran 64:11: 'No disaster strikes except by permission of Allah. And whoever believes in Allah - He will guide his heart. And Allah is Knowing of all things.'"
  ];

  static const primaryColor = Color(0xff002147);
  static const secondaryColor = Color(0xFF2A2D3E);
  static const bgColor = Color(0xFF212332);
  static const defaultPadding = 16.0;

  static String getRandomQuote() {
    final random = Random();
    int index = random.nextInt(quotes.length);
    return quotes[index];
  }
}
