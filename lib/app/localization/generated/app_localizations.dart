import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fa.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_id.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_ko.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_tr.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fa'),
    Locale('fr'),
    Locale('hi'),
    Locale('id'),
    Locale('ja'),
    Locale('ko'),
    Locale('pt'),
    Locale('ru'),
    Locale('tr'),
    Locale('zh')
  ];

  /// No description provided for @appName.
  ///
  /// In ar, this message translates to:
  /// **'صارحني'**
  String get appName;

  /// No description provided for @tagline.
  ///
  /// In ar, this message translates to:
  /// **'تعبير أصيل عن الذات'**
  String get tagline;

  /// No description provided for @splashLoading.
  ///
  /// In ar, this message translates to:
  /// **'جارٍ التحميل...'**
  String get splashLoading;

  /// No description provided for @loginTitle.
  ///
  /// In ar, this message translates to:
  /// **'أهلاً بعودتك'**
  String get loginTitle;

  /// No description provided for @loginEmailOrUsername.
  ///
  /// In ar, this message translates to:
  /// **'اسم المستخدم أو البريد'**
  String get loginEmailOrUsername;

  /// No description provided for @loginPassword.
  ///
  /// In ar, this message translates to:
  /// **'كلمة المرور'**
  String get loginPassword;

  /// No description provided for @loginButton.
  ///
  /// In ar, this message translates to:
  /// **'دخول'**
  String get loginButton;

  /// No description provided for @loginForgotPassword.
  ///
  /// In ar, this message translates to:
  /// **'نسيت كلمة المرور؟'**
  String get loginForgotPassword;

  /// No description provided for @loginNoAccount.
  ///
  /// In ar, this message translates to:
  /// **'ليس لديك حساب؟'**
  String get loginNoAccount;

  /// No description provided for @loginSignUp.
  ///
  /// In ar, this message translates to:
  /// **'سجّل'**
  String get loginSignUp;

  /// No description provided for @registerTitle.
  ///
  /// In ar, this message translates to:
  /// **'أنشئ حسابك'**
  String get registerTitle;

  /// No description provided for @registerName.
  ///
  /// In ar, this message translates to:
  /// **'الاسم'**
  String get registerName;

  /// No description provided for @registerUsername.
  ///
  /// In ar, this message translates to:
  /// **'اسم المستخدم'**
  String get registerUsername;

  /// No description provided for @registerEmail.
  ///
  /// In ar, this message translates to:
  /// **'البريد الإلكتروني'**
  String get registerEmail;

  /// No description provided for @registerPassword.
  ///
  /// In ar, this message translates to:
  /// **'كلمة المرور'**
  String get registerPassword;

  /// No description provided for @registerButton.
  ///
  /// In ar, this message translates to:
  /// **'إنشاء حساب'**
  String get registerButton;

  /// No description provided for @registerHasAccount.
  ///
  /// In ar, this message translates to:
  /// **'لديك حساب بالفعل؟'**
  String get registerHasAccount;

  /// No description provided for @registerSignIn.
  ///
  /// In ar, this message translates to:
  /// **'ادخل'**
  String get registerSignIn;

  /// No description provided for @navHome.
  ///
  /// In ar, this message translates to:
  /// **'الرئيسية'**
  String get navHome;

  /// No description provided for @navInbox.
  ///
  /// In ar, this message translates to:
  /// **'الوارد'**
  String get navInbox;

  /// No description provided for @navCompose.
  ///
  /// In ar, this message translates to:
  /// **'نشر'**
  String get navCompose;

  /// No description provided for @navMirrors.
  ///
  /// In ar, this message translates to:
  /// **'المرايا'**
  String get navMirrors;

  /// No description provided for @navProfile.
  ///
  /// In ar, this message translates to:
  /// **'حسابي'**
  String get navProfile;

  /// No description provided for @feedGlobalTab.
  ///
  /// In ar, this message translates to:
  /// **'العالمي'**
  String get feedGlobalTab;

  /// No description provided for @feedFollowingTab.
  ///
  /// In ar, this message translates to:
  /// **'أتابعهم'**
  String get feedFollowingTab;

  /// No description provided for @feedSectionAll.
  ///
  /// In ar, this message translates to:
  /// **'الكل'**
  String get feedSectionAll;

  /// No description provided for @feedSectionMoment.
  ///
  /// In ar, this message translates to:
  /// **'لحظات'**
  String get feedSectionMoment;

  /// No description provided for @feedSectionFace.
  ///
  /// In ar, this message translates to:
  /// **'صور'**
  String get feedSectionFace;

  /// No description provided for @feedSectionMind.
  ///
  /// In ar, this message translates to:
  /// **'أفكار'**
  String get feedSectionMind;

  /// No description provided for @postCrystalBadge.
  ///
  /// In ar, this message translates to:
  /// **'متبلور'**
  String get postCrystalBadge;

  /// No description provided for @postLayersHint.
  ///
  /// In ar, this message translates to:
  /// **'اقرأ'**
  String get postLayersHint;

  /// No description provided for @postGravityApproaching.
  ///
  /// In ar, this message translates to:
  /// **'يقترب من التبلور'**
  String get postGravityApproaching;

  /// No description provided for @postGravityFading.
  ///
  /// In ar, this message translates to:
  /// **'يتلاشى'**
  String get postGravityFading;

  /// No description provided for @composeChooseSection.
  ///
  /// In ar, this message translates to:
  /// **'اختر القسم'**
  String get composeChooseSection;

  /// No description provided for @composeMoment.
  ///
  /// In ar, this message translates to:
  /// **'لحظة'**
  String get composeMoment;

  /// No description provided for @composeFace.
  ///
  /// In ar, this message translates to:
  /// **'صورة'**
  String get composeFace;

  /// No description provided for @composeMind.
  ///
  /// In ar, this message translates to:
  /// **'فكرة'**
  String get composeMind;

  /// No description provided for @composeLayer1.
  ///
  /// In ar, this message translates to:
  /// **'النص الأساسي'**
  String get composeLayer1;

  /// No description provided for @composeLayer2.
  ///
  /// In ar, this message translates to:
  /// **'أضف صورة (اختياري)'**
  String get composeLayer2;

  /// No description provided for @composeLayer3.
  ///
  /// In ar, this message translates to:
  /// **'اكتب مقالاً عميقاً (اختياري)'**
  String get composeLayer3;

  /// No description provided for @composeCrystallizeHint.
  ///
  /// In ar, this message translates to:
  /// **'يبدأ بعمر 24 ساعة — يتبلور إن تجاوب'**
  String get composeCrystallizeHint;

  /// No description provided for @composePublish.
  ///
  /// In ar, this message translates to:
  /// **'نشر'**
  String get composePublish;

  /// No description provided for @profileEdit.
  ///
  /// In ar, this message translates to:
  /// **'تعديل'**
  String get profileEdit;

  /// No description provided for @profileFollow.
  ///
  /// In ar, this message translates to:
  /// **'متابعة'**
  String get profileFollow;

  /// No description provided for @profileFollowing.
  ///
  /// In ar, this message translates to:
  /// **'أتابعه'**
  String get profileFollowing;

  /// No description provided for @profileBlock.
  ///
  /// In ar, this message translates to:
  /// **'حظر'**
  String get profileBlock;

  /// No description provided for @profileFollowers.
  ///
  /// In ar, this message translates to:
  /// **'متابعون'**
  String get profileFollowers;

  /// No description provided for @profileCrystals.
  ///
  /// In ar, this message translates to:
  /// **'متبلور'**
  String get profileCrystals;

  /// No description provided for @profileReplies.
  ///
  /// In ar, this message translates to:
  /// **'الردود'**
  String get profileReplies;

  /// No description provided for @profileTabCrystals.
  ///
  /// In ar, this message translates to:
  /// **'المتبلور'**
  String get profileTabCrystals;

  /// No description provided for @profileTabActive.
  ///
  /// In ar, this message translates to:
  /// **'النشط'**
  String get profileTabActive;

  /// No description provided for @profileTabMirrors.
  ///
  /// In ar, this message translates to:
  /// **'المرايا'**
  String get profileTabMirrors;

  /// No description provided for @profileTabLikes.
  ///
  /// In ar, this message translates to:
  /// **'الإعجابات'**
  String get profileTabLikes;

  /// No description provided for @inboxTitle.
  ///
  /// In ar, this message translates to:
  /// **'الرسائل المجهولة'**
  String get inboxTitle;

  /// No description provided for @inboxEmpty.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد رسائل بعد'**
  String get inboxEmpty;

  /// No description provided for @inboxReplyPublic.
  ///
  /// In ar, this message translates to:
  /// **'رد علناً'**
  String get inboxReplyPublic;

  /// No description provided for @inboxIgnore.
  ///
  /// In ar, this message translates to:
  /// **'تجاهل'**
  String get inboxIgnore;

  /// No description provided for @inboxReport.
  ///
  /// In ar, this message translates to:
  /// **'بلاغ'**
  String get inboxReport;

  /// No description provided for @inboxDelete.
  ///
  /// In ar, this message translates to:
  /// **'حذف'**
  String get inboxDelete;

  /// No description provided for @mirrorsTitle.
  ///
  /// In ar, this message translates to:
  /// **'مرايا'**
  String get mirrorsTitle;

  /// No description provided for @mirrorsCreate.
  ///
  /// In ar, this message translates to:
  /// **'أنشئ مرآة جديدة'**
  String get mirrorsCreate;

  /// No description provided for @mirrorsShare.
  ///
  /// In ar, this message translates to:
  /// **'شارك الرابط'**
  String get mirrorsShare;

  /// No description provided for @settingsTitle.
  ///
  /// In ar, this message translates to:
  /// **'الإعدادات'**
  String get settingsTitle;

  /// No description provided for @settingsAccount.
  ///
  /// In ar, this message translates to:
  /// **'الحساب'**
  String get settingsAccount;

  /// No description provided for @settingsPrivacy.
  ///
  /// In ar, this message translates to:
  /// **'الخصوصية'**
  String get settingsPrivacy;

  /// No description provided for @settingsNotifications.
  ///
  /// In ar, this message translates to:
  /// **'الإشعارات'**
  String get settingsNotifications;

  /// No description provided for @settingsTheme.
  ///
  /// In ar, this message translates to:
  /// **'المظهر'**
  String get settingsTheme;

  /// No description provided for @settingsAnonymous.
  ///
  /// In ar, this message translates to:
  /// **'الرسائل المجهولة'**
  String get settingsAnonymous;

  /// No description provided for @settingsSubscription.
  ///
  /// In ar, this message translates to:
  /// **'الاشتراك'**
  String get settingsSubscription;

  /// No description provided for @settingsHelp.
  ///
  /// In ar, this message translates to:
  /// **'المساعدة'**
  String get settingsHelp;

  /// No description provided for @settingsLogout.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل خروج'**
  String get settingsLogout;

  /// No description provided for @themeLight.
  ///
  /// In ar, this message translates to:
  /// **'نهاري'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In ar, this message translates to:
  /// **'داكن'**
  String get themeDark;

  /// No description provided for @themeSystem.
  ///
  /// In ar, this message translates to:
  /// **'تلقائي'**
  String get themeSystem;

  /// No description provided for @commonRetry.
  ///
  /// In ar, this message translates to:
  /// **'إعادة المحاولة'**
  String get commonRetry;

  /// No description provided for @commonSave.
  ///
  /// In ar, this message translates to:
  /// **'حفظ'**
  String get commonSave;

  /// No description provided for @commonCancel.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء'**
  String get commonCancel;

  /// No description provided for @commonClose.
  ///
  /// In ar, this message translates to:
  /// **'إغلاق'**
  String get commonClose;

  /// No description provided for @commonShare.
  ///
  /// In ar, this message translates to:
  /// **'مشاركة'**
  String get commonShare;

  /// No description provided for @commonReport.
  ///
  /// In ar, this message translates to:
  /// **'بلاغ'**
  String get commonReport;

  /// No description provided for @commonDelete.
  ///
  /// In ar, this message translates to:
  /// **'حذف'**
  String get commonDelete;

  /// No description provided for @commonError.
  ///
  /// In ar, this message translates to:
  /// **'حدث خطأ'**
  String get commonError;

  /// No description provided for @commonLoading.
  ///
  /// In ar, this message translates to:
  /// **'جارٍ التحميل...'**
  String get commonLoading;

  /// No description provided for @commonEmpty.
  ///
  /// In ar, this message translates to:
  /// **'لا يوجد محتوى'**
  String get commonEmpty;

  /// No description provided for @gamesHubTitle.
  ///
  /// In ar, this message translates to:
  /// **'الألعاب'**
  String get gamesHubTitle;

  /// No description provided for @carromTitle.
  ///
  /// In ar, this message translates to:
  /// **'كيرم 1v1'**
  String get carromTitle;

  /// No description provided for @carromSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'تحدّى منافساً مجهولاً — اربح نقاطه'**
  String get carromSubtitle;

  /// No description provided for @carromLobbyPlayRandom.
  ///
  /// In ar, this message translates to:
  /// **'ابدأ مباراة عشوائية'**
  String get carromLobbyPlayRandom;

  /// No description provided for @carromLobbyPlayRandomSub.
  ///
  /// In ar, this message translates to:
  /// **'ابحث عن منافس متاح الآن'**
  String get carromLobbyPlayRandomSub;

  /// No description provided for @carromLobbyInvite.
  ///
  /// In ar, this message translates to:
  /// **'العب مع صديق'**
  String get carromLobbyInvite;

  /// No description provided for @carromLobbyInviteSub.
  ///
  /// In ar, this message translates to:
  /// **'أنشئ رمز دعوة وشاركه'**
  String get carromLobbyInviteSub;

  /// No description provided for @carromLobbyJoinByCode.
  ///
  /// In ar, this message translates to:
  /// **'انضم بدعوة'**
  String get carromLobbyJoinByCode;

  /// No description provided for @carromLobbyJoinHint.
  ///
  /// In ar, this message translates to:
  /// **'الصق الرمز'**
  String get carromLobbyJoinHint;

  /// No description provided for @carromLobbyJoinAction.
  ///
  /// In ar, this message translates to:
  /// **'انضم'**
  String get carromLobbyJoinAction;

  /// No description provided for @carromLobbyEntryFee.
  ///
  /// In ar, this message translates to:
  /// **'دخول {entry} — الفائز يأخذ {pot}'**
  String carromLobbyEntryFee(Object entry, Object pot);

  /// No description provided for @carromMmSearching.
  ///
  /// In ar, this message translates to:
  /// **'البحث عن منافس...'**
  String get carromMmSearching;

  /// No description provided for @carromMmCancel.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء البحث'**
  String get carromMmCancel;

  /// No description provided for @carromMmQueue.
  ///
  /// In ar, this message translates to:
  /// **'ترتيبك في الطابور: {pos}'**
  String carromMmQueue(Object pos);

  /// No description provided for @carromMatchYourTurn.
  ///
  /// In ar, this message translates to:
  /// **'دورك'**
  String get carromMatchYourTurn;

  /// No description provided for @carromMatchOppTurn.
  ///
  /// In ar, this message translates to:
  /// **'دور الخصم'**
  String get carromMatchOppTurn;

  /// No description provided for @carromMatchConcede.
  ///
  /// In ar, this message translates to:
  /// **'استسلام'**
  String get carromMatchConcede;

  /// No description provided for @carromMatchConcedeConfirm.
  ///
  /// In ar, this message translates to:
  /// **'إذا انسحبت الآن، يفوز خصمك بالنقاط كاملة.'**
  String get carromMatchConcedeConfirm;

  /// No description provided for @carromMatchReconnect.
  ///
  /// In ar, this message translates to:
  /// **'إعادة الاتصال بالخادم...'**
  String get carromMatchReconnect;

  /// No description provided for @carromOpponentUnknown.
  ///
  /// In ar, this message translates to:
  /// **'خصم مجهول'**
  String get carromOpponentUnknown;

  /// No description provided for @carromOpponentTurnNow.
  ///
  /// In ar, this message translates to:
  /// **'دوره الآن'**
  String get carromOpponentTurnNow;

  /// No description provided for @carromOpponentWaiting.
  ///
  /// In ar, this message translates to:
  /// **'بانتظار الدور'**
  String get carromOpponentWaiting;

  /// No description provided for @carromAimHint.
  ///
  /// In ar, this message translates to:
  /// **'اسحب من الستراكر للداخل لتصويب'**
  String get carromAimHint;

  /// No description provided for @carromGameOverWon.
  ///
  /// In ar, this message translates to:
  /// **'فزت!'**
  String get carromGameOverWon;

  /// No description provided for @carromGameOverLost.
  ///
  /// In ar, this message translates to:
  /// **'حظ أوفر'**
  String get carromGameOverLost;

  /// No description provided for @carromGameOverReveal.
  ///
  /// In ar, this message translates to:
  /// **'اكشف هويتك للخصم'**
  String get carromGameOverReveal;

  /// No description provided for @carromGameOverHide.
  ///
  /// In ar, this message translates to:
  /// **'أخفِ هويتي'**
  String get carromGameOverHide;

  /// No description provided for @carromGameOverSarhny.
  ///
  /// In ar, this message translates to:
  /// **'أرسل رسالة صراحة'**
  String get carromGameOverSarhny;

  /// No description provided for @carromGameOverRematch.
  ///
  /// In ar, this message translates to:
  /// **'مباراة جديدة'**
  String get carromGameOverRematch;

  /// No description provided for @carromGameOverLobby.
  ///
  /// In ar, this message translates to:
  /// **'اللوبي'**
  String get carromGameOverLobby;

  /// No description provided for @carromWalletEarn1.
  ///
  /// In ar, this message translates to:
  /// **'كل رسالة صراحة تستقبلها'**
  String get carromWalletEarn1;

  /// No description provided for @carromWalletEarn2.
  ///
  /// In ar, this message translates to:
  /// **'مشاهدة إعلان قصير'**
  String get carromWalletEarn2;

  /// No description provided for @carromWalletEarn3.
  ///
  /// In ar, this message translates to:
  /// **'الفوز في مباراة كيرم'**
  String get carromWalletEarn3;

  /// No description provided for @carromCosmeticsTitle.
  ///
  /// In ar, this message translates to:
  /// **'خصّص لعبتك'**
  String get carromCosmeticsTitle;

  /// No description provided for @carromCosmeticsTabBoard.
  ///
  /// In ar, this message translates to:
  /// **'الطاولة'**
  String get carromCosmeticsTabBoard;

  /// No description provided for @carromCosmeticsTabPieces.
  ///
  /// In ar, this message translates to:
  /// **'القطع'**
  String get carromCosmeticsTabPieces;

  /// No description provided for @carromCosmeticsTabStriker.
  ///
  /// In ar, this message translates to:
  /// **'المضرب'**
  String get carromCosmeticsTabStriker;

  /// No description provided for @carromCosmeticsLockedHint.
  ///
  /// In ar, this message translates to:
  /// **'اربح نقاطاً لفتح هذا الشكل'**
  String get carromCosmeticsLockedHint;

  /// No description provided for @carromCosmeticsSaved.
  ///
  /// In ar, this message translates to:
  /// **'تم اختيار {name}'**
  String carromCosmeticsSaved(Object name);

  /// No description provided for @carromCosmeticsSaveFailed.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر الحفظ، حاول مرة أخرى'**
  String get carromCosmeticsSaveFailed;

  /// No description provided for @carromLobbyCustomize.
  ///
  /// In ar, this message translates to:
  /// **'تخصيص لعبتك'**
  String get carromLobbyCustomize;

  /// No description provided for @carromLobbyCustomizeSub.
  ///
  /// In ar, this message translates to:
  /// **'اختر طاولتك ولون أحجارك ومضربك'**
  String get carromLobbyCustomizeSub;

  /// No description provided for @actionPlay.
  ///
  /// In ar, this message translates to:
  /// **'العب'**
  String get actionPlay;

  /// No description provided for @actionPlayAgain.
  ///
  /// In ar, this message translates to:
  /// **'العب مرة أخرى'**
  String get actionPlayAgain;

  /// No description provided for @actionRetry.
  ///
  /// In ar, this message translates to:
  /// **'إعادة المحاولة'**
  String get actionRetry;

  /// No description provided for @actionConfirm.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد'**
  String get actionConfirm;

  /// No description provided for @actionSend.
  ///
  /// In ar, this message translates to:
  /// **'إرسال'**
  String get actionSend;

  /// No description provided for @actionSkip.
  ///
  /// In ar, this message translates to:
  /// **'تخطي'**
  String get actionSkip;

  /// No description provided for @actionLockIn.
  ///
  /// In ar, this message translates to:
  /// **'تثبيت'**
  String get actionLockIn;

  /// No description provided for @actionDiscard.
  ///
  /// In ar, this message translates to:
  /// **'تجاهل'**
  String get actionDiscard;

  /// No description provided for @actionBack.
  ///
  /// In ar, this message translates to:
  /// **'رجوع'**
  String get actionBack;

  /// No description provided for @actionLeave.
  ///
  /// In ar, this message translates to:
  /// **'خروج'**
  String get actionLeave;

  /// No description provided for @actionLeaveLobby.
  ///
  /// In ar, this message translates to:
  /// **'العودة للوبي'**
  String get actionLeaveLobby;

  /// No description provided for @actionJoin.
  ///
  /// In ar, this message translates to:
  /// **'انضم'**
  String get actionJoin;

  /// No description provided for @actionCopy.
  ///
  /// In ar, this message translates to:
  /// **'نسخ'**
  String get actionCopy;

  /// No description provided for @actionPaste.
  ///
  /// In ar, this message translates to:
  /// **'لصق'**
  String get actionPaste;

  /// No description provided for @actionDone.
  ///
  /// In ar, this message translates to:
  /// **'تم'**
  String get actionDone;

  /// No description provided for @labelLobby.
  ///
  /// In ar, this message translates to:
  /// **'اللوبي'**
  String get labelLobby;

  /// No description provided for @labelGamesHome.
  ///
  /// In ar, this message translates to:
  /// **'الساحة'**
  String get labelGamesHome;

  /// No description provided for @labelOpponent.
  ///
  /// In ar, this message translates to:
  /// **'الخصم'**
  String get labelOpponent;

  /// No description provided for @labelYou.
  ///
  /// In ar, this message translates to:
  /// **'أنت'**
  String get labelYou;

  /// No description provided for @labelMe.
  ///
  /// In ar, this message translates to:
  /// **'أنا'**
  String get labelMe;

  /// No description provided for @labelAi.
  ///
  /// In ar, this message translates to:
  /// **'الذكاء'**
  String get labelAi;

  /// No description provided for @labelVs.
  ///
  /// In ar, this message translates to:
  /// **'ضد'**
  String get labelVs;

  /// No description provided for @labelTurnYours.
  ///
  /// In ar, this message translates to:
  /// **'دورك'**
  String get labelTurnYours;

  /// No description provided for @labelTurnTheirs.
  ///
  /// In ar, this message translates to:
  /// **'دور الخصم'**
  String get labelTurnTheirs;

  /// No description provided for @labelTurnAi.
  ///
  /// In ar, this message translates to:
  /// **'الذكاء يفكّر…'**
  String get labelTurnAi;

  /// No description provided for @labelRound.
  ///
  /// In ar, this message translates to:
  /// **'جولة {n}'**
  String labelRound(Object n);

  /// No description provided for @labelWaiting.
  ///
  /// In ar, this message translates to:
  /// **'بانتظار…'**
  String get labelWaiting;

  /// No description provided for @labelWaitingOpponent.
  ///
  /// In ar, this message translates to:
  /// **'بانتظار الخصم…'**
  String get labelWaitingOpponent;

  /// No description provided for @labelSearching.
  ///
  /// In ar, this message translates to:
  /// **'البحث عن منافس…'**
  String get labelSearching;

  /// No description provided for @outcomeYouWon.
  ///
  /// In ar, this message translates to:
  /// **'فزت!'**
  String get outcomeYouWon;

  /// No description provided for @outcomeYouLost.
  ///
  /// In ar, this message translates to:
  /// **'خسرت'**
  String get outcomeYouLost;

  /// No description provided for @outcomeDraw.
  ///
  /// In ar, this message translates to:
  /// **'تعادل'**
  String get outcomeDraw;

  /// No description provided for @outcomeAiWins.
  ///
  /// In ar, this message translates to:
  /// **'الذكاء فاز'**
  String get outcomeAiWins;

  /// No description provided for @moodLight.
  ///
  /// In ar, this message translates to:
  /// **'خفيف'**
  String get moodLight;

  /// No description provided for @moodBold.
  ///
  /// In ar, this message translates to:
  /// **'جريء'**
  String get moodBold;

  /// No description provided for @moodFunny.
  ///
  /// In ar, this message translates to:
  /// **'مضحك'**
  String get moodFunny;

  /// No description provided for @moodChoose.
  ///
  /// In ar, this message translates to:
  /// **'اختر مزاج اللعبة'**
  String get moodChoose;

  /// No description provided for @lobbyVsRandom.
  ///
  /// In ar, this message translates to:
  /// **'منافس عشوائي'**
  String get lobbyVsRandom;

  /// No description provided for @lobbyVsAi.
  ///
  /// In ar, this message translates to:
  /// **'ضد الذكاء'**
  String get lobbyVsAi;

  /// No description provided for @lobbyVsAiSub.
  ///
  /// In ar, this message translates to:
  /// **'تدريب فوري — الذكاء يطرح سؤالاً إذا فاز'**
  String get lobbyVsAiSub;

  /// No description provided for @lobbyInviteFriend.
  ///
  /// In ar, this message translates to:
  /// **'العب مع صديق'**
  String get lobbyInviteFriend;

  /// No description provided for @lobbyInviteFriendSub.
  ///
  /// In ar, this message translates to:
  /// **'أنشئ رمز دعوة وشاركه'**
  String get lobbyInviteFriendSub;

  /// No description provided for @lobbyJoinByCode.
  ///
  /// In ar, this message translates to:
  /// **'انضم بدعوة'**
  String get lobbyJoinByCode;

  /// No description provided for @lobbyPasteCode.
  ///
  /// In ar, this message translates to:
  /// **'الصق الرمز'**
  String get lobbyPasteCode;

  /// No description provided for @questionAsk.
  ///
  /// In ar, this message translates to:
  /// **'اطرح سؤالك'**
  String get questionAsk;

  /// No description provided for @questionAnswer.
  ///
  /// In ar, this message translates to:
  /// **'أجب بصدق'**
  String get questionAnswer;

  /// No description provided for @questionWaitingQ.
  ///
  /// In ar, this message translates to:
  /// **'بانتظار سؤال الخصم…'**
  String get questionWaitingQ;

  /// No description provided for @questionWaitingA.
  ///
  /// In ar, this message translates to:
  /// **'بانتظار إجابة الخصم…'**
  String get questionWaitingA;

  /// No description provided for @questionSkipNew.
  ///
  /// In ar, this message translates to:
  /// **'بدّل السؤال'**
  String get questionSkipNew;

  /// No description provided for @questionAbstainAd.
  ///
  /// In ar, this message translates to:
  /// **'امتنع · شاهد إعلاناً (+1 نقطة)'**
  String get questionAbstainAd;

  /// No description provided for @questionAbstainNote.
  ///
  /// In ar, this message translates to:
  /// **'الامتناع ينهي المباراة بدون إجابة ويضيف نقطة لرصيدك.'**
  String get questionAbstainNote;

  /// No description provided for @adLoading.
  ///
  /// In ar, this message translates to:
  /// **'جاري تحميل الإعلان…'**
  String get adLoading;

  /// No description provided for @adIncomplete.
  ///
  /// In ar, this message translates to:
  /// **'الإعلان لم يكتمل'**
  String get adIncomplete;

  /// No description provided for @adUnavailable.
  ///
  /// In ar, this message translates to:
  /// **'لا يوجد إعلان متاح'**
  String get adUnavailable;

  /// No description provided for @adDailyCap.
  ///
  /// In ar, this message translates to:
  /// **'وصلت الحد اليومي للإعلانات'**
  String get adDailyCap;

  /// No description provided for @adRewardEarned.
  ///
  /// In ar, this message translates to:
  /// **'حصلت على نقطة. تم الامتناع.'**
  String get adRewardEarned;

  /// No description provided for @rpsRock.
  ///
  /// In ar, this message translates to:
  /// **'حجر'**
  String get rpsRock;

  /// No description provided for @rpsPaper.
  ///
  /// In ar, this message translates to:
  /// **'ورقة'**
  String get rpsPaper;

  /// No description provided for @rpsScissors.
  ///
  /// In ar, this message translates to:
  /// **'مقص'**
  String get rpsScissors;

  /// No description provided for @rpsChooseHand.
  ///
  /// In ar, this message translates to:
  /// **'اختر يدك'**
  String get rpsChooseHand;

  /// No description provided for @rpsGuessHand.
  ///
  /// In ar, this message translates to:
  /// **'خمّن يد الخصم'**
  String get rpsGuessHand;

  /// No description provided for @rpsAiQuestionLabel.
  ///
  /// In ar, this message translates to:
  /// **'سؤال الذكاء'**
  String get rpsAiQuestionLabel;

  /// No description provided for @rpsMyQuestionLabel.
  ///
  /// In ar, this message translates to:
  /// **'سؤالك للذكاء'**
  String get rpsMyQuestionLabel;

  /// No description provided for @rpsAnswerPrivate.
  ///
  /// In ar, this message translates to:
  /// **'الإجابة لك وحدك — لا تُحفظ ولا تُرسل.'**
  String get rpsAnswerPrivate;

  /// No description provided for @xoCellFilled.
  ///
  /// In ar, this message translates to:
  /// **'الخانة مشغولة — اختر أخرى'**
  String get xoCellFilled;

  /// No description provided for @xoNotYourTurn.
  ///
  /// In ar, this message translates to:
  /// **'ليس دورك بعد'**
  String get xoNotYourTurn;

  /// No description provided for @xoPracticeTitle.
  ///
  /// In ar, this message translates to:
  /// **'XO — تدريب'**
  String get xoPracticeTitle;

  /// No description provided for @leaveTitle.
  ///
  /// In ar, this message translates to:
  /// **'مغادرة المباراة؟'**
  String get leaveTitle;

  /// No description provided for @leaveBody.
  ///
  /// In ar, this message translates to:
  /// **'ستُحتسب جولتك خسارة.'**
  String get leaveBody;

  /// No description provided for @rematchTitle.
  ///
  /// In ar, this message translates to:
  /// **'هل تريد إعادة المباراة؟'**
  String get rematchTitle;

  /// No description provided for @rematchAccept.
  ///
  /// In ar, this message translates to:
  /// **'إعادة المباراة'**
  String get rematchAccept;

  /// No description provided for @rematchDecline.
  ///
  /// In ar, this message translates to:
  /// **'انتهيت'**
  String get rematchDecline;

  /// No description provided for @rematchWaiting.
  ///
  /// In ar, this message translates to:
  /// **'بانتظار رد الخصم…'**
  String get rematchWaiting;

  /// No description provided for @rematchDeclined.
  ///
  /// In ar, this message translates to:
  /// **'الخصم رفض الإعادة'**
  String get rematchDeclined;

  /// No description provided for @rematchTimeout.
  ///
  /// In ar, this message translates to:
  /// **'انتهى وقت الطلب'**
  String get rematchTimeout;

  /// No description provided for @hubGameRps.
  ///
  /// In ar, this message translates to:
  /// **'تحدّى'**
  String get hubGameRps;

  /// No description provided for @hubGameRpsSub.
  ///
  /// In ar, this message translates to:
  /// **'حجرة · ورقة · مقص — الفائز يطرح السؤال'**
  String get hubGameRpsSub;

  /// No description provided for @hubGameXo.
  ///
  /// In ar, this message translates to:
  /// **'إكس-أو'**
  String get hubGameXo;

  /// No description provided for @hubGameXoSub.
  ///
  /// In ar, this message translates to:
  /// **'ثلاثة على التوالي — الفائز يطرح السؤال'**
  String get hubGameXoSub;

  /// No description provided for @hubAdEarnTitle.
  ///
  /// In ar, this message translates to:
  /// **'شاهد إعلاناً قصيراً'**
  String get hubAdEarnTitle;

  /// No description provided for @hubAdEarnSub.
  ///
  /// In ar, this message translates to:
  /// **'حد يومي ١٠ — جميع النقاط تُضاف لمحفظتك فوراً.'**
  String get hubAdEarnSub;

  /// No description provided for @hubAdPointBadge.
  ///
  /// In ar, this message translates to:
  /// **'+1 نقطة'**
  String get hubAdPointBadge;

  /// No description provided for @hubTagAdNew.
  ///
  /// In ar, this message translates to:
  /// **'جديد'**
  String get hubTagAdNew;

  /// No description provided for @hubTagOnline.
  ///
  /// In ar, this message translates to:
  /// **'أونلاين'**
  String get hubTagOnline;

  /// No description provided for @hubSectionPlay.
  ///
  /// In ar, this message translates to:
  /// **'العب الآن'**
  String get hubSectionPlay;

  /// No description provided for @hubSectionEarn.
  ///
  /// In ar, this message translates to:
  /// **'اربح نقاطاً بدون لعب'**
  String get hubSectionEarn;

  /// No description provided for @hubAbstainHint.
  ///
  /// In ar, this message translates to:
  /// **'تستطيع أيضاً الامتناع عن الجواب خلال اللعبة بمشاهدة إعلان.'**
  String get hubAbstainHint;

  /// No description provided for @settingsLanguage.
  ///
  /// In ar, this message translates to:
  /// **'اللغة'**
  String get settingsLanguage;

  /// No description provided for @settingsLanguageAuto.
  ///
  /// In ar, this message translates to:
  /// **'تلقائي (لغة الجهاز)'**
  String get settingsLanguageAuto;

  /// No description provided for @settingsEmail.
  ///
  /// In ar, this message translates to:
  /// **'البريد الإلكتروني'**
  String get settingsEmail;

  /// No description provided for @settingsChangePassword.
  ///
  /// In ar, this message translates to:
  /// **'تغيير كلمة المرور'**
  String get settingsChangePassword;

  /// No description provided for @settingsAnonymousReceive.
  ///
  /// In ar, this message translates to:
  /// **'استقبال الرسائل المجهولة'**
  String get settingsAnonymousReceive;

  /// No description provided for @settingsVoiceReceive.
  ///
  /// In ar, this message translates to:
  /// **'استقبال الرسائل الصوتية'**
  String get settingsVoiceReceive;

  /// No description provided for @settingsImageReceive.
  ///
  /// In ar, this message translates to:
  /// **'استقبال الصور'**
  String get settingsImageReceive;

  /// No description provided for @settingsRegisteredOnly.
  ///
  /// In ar, this message translates to:
  /// **'من الأعضاء المسجّلين فقط'**
  String get settingsRegisteredOnly;

  /// No description provided for @settingsBlockedAccounts.
  ///
  /// In ar, this message translates to:
  /// **'الحسابات المحظورة'**
  String get settingsBlockedAccounts;

  /// No description provided for @settingsLikes.
  ///
  /// In ar, this message translates to:
  /// **'إعجابات'**
  String get settingsLikes;

  /// No description provided for @settingsComments.
  ///
  /// In ar, this message translates to:
  /// **'تعليقات'**
  String get settingsComments;

  /// No description provided for @settingsFollowers.
  ///
  /// In ar, this message translates to:
  /// **'متابعون جدد'**
  String get settingsFollowers;

  /// No description provided for @settingsAppearance.
  ///
  /// In ar, this message translates to:
  /// **'المظهر'**
  String get settingsAppearance;

  /// No description provided for @settingsGeneral.
  ///
  /// In ar, this message translates to:
  /// **'عام'**
  String get settingsGeneral;

  /// No description provided for @settingsHelpCenter.
  ///
  /// In ar, this message translates to:
  /// **'مركز المساعدة'**
  String get settingsHelpCenter;

  /// No description provided for @settingsTerms.
  ///
  /// In ar, this message translates to:
  /// **'شروط الاستخدام'**
  String get settingsTerms;

  /// No description provided for @settingsPrivacyPolicy.
  ///
  /// In ar, this message translates to:
  /// **'سياسة الخصوصية'**
  String get settingsPrivacyPolicy;

  /// No description provided for @settingsContentPolicy.
  ///
  /// In ar, this message translates to:
  /// **'سياسة المحتوى'**
  String get settingsContentPolicy;

  /// No description provided for @settingsDangerZone.
  ///
  /// In ar, this message translates to:
  /// **'منطقة خطرة'**
  String get settingsDangerZone;

  /// No description provided for @settingsDeleteAccount.
  ///
  /// In ar, this message translates to:
  /// **'حذف الحساب'**
  String get settingsDeleteAccount;

  /// No description provided for @settingsUpdated.
  ///
  /// In ar, this message translates to:
  /// **'تم التحديث'**
  String get settingsUpdated;

  /// No description provided for @settingsUpdateFailed.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر التحديث'**
  String get settingsUpdateFailed;

  /// No description provided for @settingsPasswordShort.
  ///
  /// In ar, this message translates to:
  /// **'كلمة المرور الجديدة قصيرة'**
  String get settingsPasswordShort;

  /// No description provided for @settingsPasswordCurrent.
  ///
  /// In ar, this message translates to:
  /// **'كلمة المرور الحالية'**
  String get settingsPasswordCurrent;

  /// No description provided for @settingsPasswordNew.
  ///
  /// In ar, this message translates to:
  /// **'كلمة المرور الجديدة'**
  String get settingsPasswordNew;

  /// No description provided for @settingsDeleteConfirmTitle.
  ///
  /// In ar, this message translates to:
  /// **'حذف الحساب نهائيًا'**
  String get settingsDeleteConfirmTitle;

  /// No description provided for @settingsDeleteConfirmBody.
  ///
  /// In ar, this message translates to:
  /// **'هذا الإجراء لا يمكن التراجع عنه — كل بياناتك ستُحذف.'**
  String get settingsDeleteConfirmBody;

  /// No description provided for @settingsDeleteConfirmField.
  ///
  /// In ar, this message translates to:
  /// **'أكّد كلمة المرور'**
  String get settingsDeleteConfirmField;

  /// No description provided for @settingsDeleteAction.
  ///
  /// In ar, this message translates to:
  /// **'احذف'**
  String get settingsDeleteAction;

  /// No description provided for @settingsDeleteFailed.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر الحذف'**
  String get settingsDeleteFailed;

  /// No description provided for @settingsThemeAuto.
  ///
  /// In ar, this message translates to:
  /// **'تلقائي'**
  String get settingsThemeAuto;

  /// No description provided for @errorGeneric.
  ///
  /// In ar, this message translates to:
  /// **'حدث خطأ'**
  String get errorGeneric;

  /// No description provided for @errorMatchLoad.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر تحميل المباراة'**
  String get errorMatchLoad;

  /// No description provided for @errorGameStart.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر بدء اللعبة'**
  String get errorGameStart;

  /// No description provided for @errorAdLaunch.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر تشغيل الإعلان'**
  String get errorAdLaunch;

  /// No description provided for @errorClipboardCopied.
  ///
  /// In ar, this message translates to:
  /// **'تم النسخ'**
  String get errorClipboardCopied;

  /// No description provided for @roundWon.
  ///
  /// In ar, this message translates to:
  /// **'ربحت الجولة'**
  String get roundWon;

  /// No description provided for @roundLost.
  ///
  /// In ar, this message translates to:
  /// **'الخصم ربح الجولة'**
  String get roundLost;

  /// No description provided for @roundDraw.
  ///
  /// In ar, this message translates to:
  /// **'لا فائز هذه الجولة'**
  String get roundDraw;

  /// No description provided for @gameOverTitle.
  ///
  /// In ar, this message translates to:
  /// **'انتهت المباراة'**
  String get gameOverTitle;

  /// No description provided for @revealingSoon.
  ///
  /// In ar, this message translates to:
  /// **'يكشف الآن…'**
  String get revealingSoon;

  /// No description provided for @nextRoundSoon.
  ///
  /// In ar, this message translates to:
  /// **'الجولة التالية تبدأ الآن…'**
  String get nextRoundSoon;

  /// No description provided for @leaveStay.
  ///
  /// In ar, this message translates to:
  /// **'ابقَ'**
  String get leaveStay;

  /// No description provided for @answerWriteHint.
  ///
  /// In ar, this message translates to:
  /// **'اكتب إجابتك بصراحة'**
  String get answerWriteHint;

  /// No description provided for @questionWriteHint.
  ///
  /// In ar, this message translates to:
  /// **'اكتب سؤالك بصدق'**
  String get questionWriteHint;

  /// No description provided for @continueMatch.
  ///
  /// In ar, this message translates to:
  /// **'متابعة'**
  String get continueMatch;

  /// No description provided for @xoPageTitle.
  ///
  /// In ar, this message translates to:
  /// **'إكس-أو تحدّى'**
  String get xoPageTitle;

  /// No description provided for @xoMovesProgress.
  ///
  /// In ar, this message translates to:
  /// **'حركة {moves}/{total}'**
  String xoMovesProgress(Object moves, Object total);

  /// No description provided for @questionUsePresetCta.
  ///
  /// In ar, this message translates to:
  /// **'أو استخدم سؤالاً جاهزاً'**
  String get questionUsePresetCta;

  /// No description provided for @questionSkipUsed.
  ///
  /// In ar, this message translates to:
  /// **'استُخدم التبديل'**
  String get questionSkipUsed;

  /// No description provided for @questionYoursPrefix.
  ///
  /// In ar, this message translates to:
  /// **'سؤالك: {q}'**
  String questionYoursPrefix(Object q);

  /// No description provided for @xoLocalDrawSub.
  ///
  /// In ar, this message translates to:
  /// **'لعبة متكافئة.'**
  String get xoLocalDrawSub;

  /// No description provided for @xoLocalWinSub.
  ///
  /// In ar, this message translates to:
  /// **'إكس-أو على التوالي — أداء جيد.'**
  String get xoLocalWinSub;

  /// No description provided for @xoLocalLoseSub.
  ///
  /// In ar, this message translates to:
  /// **'حاول مرة أخرى.'**
  String get xoLocalLoseSub;

  /// No description provided for @lobbyStartMatchSection.
  ///
  /// In ar, this message translates to:
  /// **'ابدأ المباراة'**
  String get lobbyStartMatchSection;

  /// No description provided for @lobbyVsRandomSub.
  ///
  /// In ar, this message translates to:
  /// **'ابحث عن لاعب أونلاين'**
  String get lobbyVsRandomSub;

  /// No description provided for @xoLobbyHeroDescription.
  ///
  /// In ar, this message translates to:
  /// **'اسبق خصمك بثلاث علامات على التوالي.\nالفائز يطرح السؤال. الخاسر يجيب.'**
  String get xoLobbyHeroDescription;

  /// No description provided for @gamePageTitle.
  ///
  /// In ar, this message translates to:
  /// **'تحدّى 🎮'**
  String get gamePageTitle;

  /// No description provided for @gameLobbyRandomSub.
  ///
  /// In ar, this message translates to:
  /// **'٥ جولات حجر/ورقة/مقص + تخمين • أول من يصل ٥ نقاط يفوز'**
  String get gameLobbyRandomSub;

  /// No description provided for @gameRulesTitle.
  ///
  /// In ar, this message translates to:
  /// **'قواعد سريعة'**
  String get gameRulesTitle;

  /// No description provided for @gameRule1.
  ///
  /// In ar, this message translates to:
  /// **'اختر سؤالاً وخمّن اختيار خصمك'**
  String get gameRule1;

  /// No description provided for @gameRule2.
  ///
  /// In ar, this message translates to:
  /// **'فوز الجولة = نقطة. تخمين صحيح = نقطة'**
  String get gameRule2;

  /// No description provided for @gameRule3.
  ///
  /// In ar, this message translates to:
  /// **'أول من يصل ٥ نقاط يربح'**
  String get gameRule3;

  /// No description provided for @gameRule4.
  ///
  /// In ar, this message translates to:
  /// **'الفائز يكتب سؤالاً للخاسر (له ٢٥ ثانية)'**
  String get gameRule4;

  /// No description provided for @gameRule5.
  ///
  /// In ar, this message translates to:
  /// **'إجابات أو أسئلة مسيئة → الجولة تُلغى'**
  String get gameRule5;

  /// No description provided for @gameUnusualEndSub.
  ///
  /// In ar, this message translates to:
  /// **'الجولة انتهت بشكل غير اعتيادي.'**
  String get gameUnusualEndSub;

  /// No description provided for @gameAnonymityTagline.
  ///
  /// In ar, this message translates to:
  /// **'لا تكشف هويتك. لا تكشف هوية خصمك.'**
  String get gameAnonymityTagline;

  /// No description provided for @secondsRemaining.
  ///
  /// In ar, this message translates to:
  /// **'{n} ثانية متبقية'**
  String secondsRemaining(Object n);

  /// No description provided for @secondsToAnswer.
  ///
  /// In ar, this message translates to:
  /// **'{n} ثانية للإجابة'**
  String secondsToAnswer(Object n);

  /// No description provided for @secondsShort.
  ///
  /// In ar, this message translates to:
  /// **'{n} ثانية'**
  String secondsShort(Object n);

  /// No description provided for @questionAutoFallbackPrefix.
  ///
  /// In ar, this message translates to:
  /// **'السؤال التلقائي إن لم تكتب:'**
  String get questionAutoFallbackPrefix;

  /// No description provided for @questionFromOpponent.
  ///
  /// In ar, this message translates to:
  /// **'سؤال من خصمك'**
  String get questionFromOpponent;

  /// No description provided for @questionAppearingSoon.
  ///
  /// In ar, this message translates to:
  /// **'السؤال سيظهر بعد لحظات. ابقَ صبوراً.'**
  String get questionAppearingSoon;

  /// No description provided for @questionSent.
  ///
  /// In ar, this message translates to:
  /// **'السؤال انطلق — لحظة وتصلك إجابته.'**
  String get questionSent;

  /// No description provided for @rpsPracticeTitle.
  ///
  /// In ar, this message translates to:
  /// **'تحدّى — تدريب'**
  String get rpsPracticeTitle;

  /// No description provided for @rpsLocalAskHint.
  ///
  /// In ar, this message translates to:
  /// **'اطرح سؤالاً صريحاً... (للمتعة فقط)'**
  String get rpsLocalAskHint;

  /// No description provided for @rpsLocalAiPreparing.
  ///
  /// In ar, this message translates to:
  /// **'يحضّر سؤالاً...'**
  String get rpsLocalAiPreparing;

  /// No description provided for @rpsLocalAnswerHint.
  ///
  /// In ar, this message translates to:
  /// **'أجب لنفسك...'**
  String get rpsLocalAnswerHint;

  /// No description provided for @ludoPowerTitle.
  ///
  /// In ar, this message translates to:
  /// **'لودو القدرات'**
  String get ludoPowerTitle;

  /// No description provided for @ludoPowerSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'لودو ٤ لاعبين مع قدرات خارقة — صاروخ، تجميد، بوابة، إعصار. القدرات تتبدّل أماكنها كل ٣ رميات.'**
  String get ludoPowerSubtitle;

  /// No description provided for @ludoLobbyChooseMode.
  ///
  /// In ar, this message translates to:
  /// **'اختر النمط'**
  String get ludoLobbyChooseMode;

  /// No description provided for @ludoMode2Players.
  ///
  /// In ar, this message translates to:
  /// **'لاعبان (١ ضد ١)'**
  String get ludoMode2Players;

  /// No description provided for @ludoMode2PlayersSub.
  ///
  /// In ar, this message translates to:
  /// **'أنت ضد بوت — أسرع وأكثف'**
  String get ludoMode2PlayersSub;

  /// No description provided for @ludoMode4Players.
  ///
  /// In ar, this message translates to:
  /// **'أربعة لاعبين'**
  String get ludoMode4Players;

  /// No description provided for @ludoMode4PlayersSub.
  ///
  /// In ar, this message translates to:
  /// **'أنت ضد ٣ بوتات — تجربة كاملة'**
  String get ludoMode4PlayersSub;

  /// No description provided for @ludoStartTap.
  ///
  /// In ar, this message translates to:
  /// **'اضغط على النرد لتبدأ'**
  String get ludoStartTap;

  /// No description provided for @ludoTapPawn.
  ///
  /// In ar, this message translates to:
  /// **'اختر قطعة لتحريكها'**
  String get ludoTapPawn;

  /// No description provided for @ludoExtraTurn.
  ///
  /// In ar, this message translates to:
  /// **'دور إضافي! ارمِ مجدداً'**
  String get ludoExtraTurn;

  /// No description provided for @ludoYourTurn.
  ///
  /// In ar, this message translates to:
  /// **'دورك — ارمِ النرد'**
  String get ludoYourTurn;

  /// No description provided for @ludoBotTurn.
  ///
  /// In ar, this message translates to:
  /// **'{name} يلعب…'**
  String ludoBotTurn(Object name);

  /// No description provided for @ludoRollDice.
  ///
  /// In ar, this message translates to:
  /// **'ارمِ النرد'**
  String get ludoRollDice;

  /// No description provided for @ludoTurnLabel.
  ///
  /// In ar, this message translates to:
  /// **'دور {name}'**
  String ludoTurnLabel(Object name);

  /// No description provided for @ludoYouWin.
  ///
  /// In ar, this message translates to:
  /// **'🎉 فزت!'**
  String get ludoYouWin;

  /// No description provided for @ludoBotWin.
  ///
  /// In ar, this message translates to:
  /// **'{name} فاز'**
  String ludoBotWin(Object name);

  /// No description provided for @ludoYouWinSub.
  ///
  /// In ar, this message translates to:
  /// **'أوصلت أحجارك الأربعة للمركز'**
  String get ludoYouWinSub;

  /// No description provided for @ludoLossSub.
  ///
  /// In ar, this message translates to:
  /// **'حظ أوفر في الجولة القادمة'**
  String get ludoLossSub;

  /// No description provided for @ludoNewGame.
  ///
  /// In ar, this message translates to:
  /// **'لعبة جديدة'**
  String get ludoNewGame;

  /// No description provided for @ludoNoMove.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد حركة'**
  String get ludoNoMove;

  /// No description provided for @ludoPlayerGold.
  ///
  /// In ar, this message translates to:
  /// **'الذهبي'**
  String get ludoPlayerGold;

  /// No description provided for @ludoPlayerBlue.
  ///
  /// In ar, this message translates to:
  /// **'الأزرق'**
  String get ludoPlayerBlue;

  /// No description provided for @ludoPlayerPurple.
  ///
  /// In ar, this message translates to:
  /// **'البنفسجي'**
  String get ludoPlayerPurple;

  /// No description provided for @ludoPlayerGreen.
  ///
  /// In ar, this message translates to:
  /// **'الأخضر'**
  String get ludoPlayerGreen;

  /// No description provided for @ludoEventRocket.
  ///
  /// In ar, this message translates to:
  /// **'صاروخ! +{boost}'**
  String ludoEventRocket(Object boost);

  /// No description provided for @ludoEventFreeze.
  ///
  /// In ar, this message translates to:
  /// **'تجمّدت!'**
  String get ludoEventFreeze;

  /// No description provided for @ludoEventPortalForward.
  ///
  /// In ar, this message translates to:
  /// **'بوابة! +{diff}'**
  String ludoEventPortalForward(Object diff);

  /// No description provided for @ludoEventPortalBack.
  ///
  /// In ar, this message translates to:
  /// **'بوابة! -{diff}'**
  String ludoEventPortalBack(Object diff);

  /// No description provided for @ludoEventTornado.
  ///
  /// In ar, this message translates to:
  /// **'إعصار!'**
  String get ludoEventTornado;

  /// No description provided for @ludoEventCapture.
  ///
  /// In ar, this message translates to:
  /// **'أكلت حجراً!'**
  String get ludoEventCapture;

  /// No description provided for @ludoEventShuffle.
  ///
  /// In ar, this message translates to:
  /// **'تبدّلت القدرات'**
  String get ludoEventShuffle;

  /// No description provided for @hubGameLudoPower.
  ///
  /// In ar, this message translates to:
  /// **'لودو القدرات'**
  String get hubGameLudoPower;

  /// No description provided for @hubGameLudoPowerSub.
  ///
  /// In ar, this message translates to:
  /// **'لودو ٤ لاعبين بقدرات خارقة — مميّز'**
  String get hubGameLudoPowerSub;

  /// No description provided for @hubTagFeatured.
  ///
  /// In ar, this message translates to:
  /// **'مميّز'**
  String get hubTagFeatured;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
        'ar',
        'de',
        'en',
        'es',
        'fa',
        'fr',
        'hi',
        'id',
        'ja',
        'ko',
        'pt',
        'ru',
        'tr',
        'zh'
      ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fa':
      return AppLocalizationsFa();
    case 'fr':
      return AppLocalizationsFr();
    case 'hi':
      return AppLocalizationsHi();
    case 'id':
      return AppLocalizationsId();
    case 'ja':
      return AppLocalizationsJa();
    case 'ko':
      return AppLocalizationsKo();
    case 'pt':
      return AppLocalizationsPt();
    case 'ru':
      return AppLocalizationsRu();
    case 'tr':
      return AppLocalizationsTr();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
