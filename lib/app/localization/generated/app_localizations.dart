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
  /// **'دورك'**
  String get ludoYourTurn;

  /// No description provided for @ludoBotTurn.
  ///
  /// In ar, this message translates to:
  /// **'{name} يلعب…'**
  String ludoBotTurn(Object name);

  /// No description provided for @ludoRollDice.
  ///
  /// In ar, this message translates to:
  /// **'ارم النرد'**
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

  /// No description provided for @ludoPlayerYou.
  ///
  /// In ar, this message translates to:
  /// **'أنت'**
  String get ludoPlayerYou;

  /// No description provided for @ludoOpponentN.
  ///
  /// In ar, this message translates to:
  /// **'الخصم {n}'**
  String ludoOpponentN(Object n);

  /// No description provided for @ludoBotThinking.
  ///
  /// In ar, this message translates to:
  /// **'يفكر…'**
  String get ludoBotThinking;

  /// No description provided for @ludoMmTitle.
  ///
  /// In ar, this message translates to:
  /// **'إيجاد خصم'**
  String get ludoMmTitle;

  /// No description provided for @ludoMmSearching.
  ///
  /// In ar, this message translates to:
  /// **'جاري البحث عن لاعبين…'**
  String get ludoMmSearching;

  /// No description provided for @ludoMmRealPlayers.
  ///
  /// In ar, this message translates to:
  /// **'نبحث عن لاعبين حقيقيين'**
  String get ludoMmRealPlayers;

  /// No description provided for @ludoMmCountdownHint.
  ///
  /// In ar, this message translates to:
  /// **'نكمل ببوتات بعد {seconds} ثانية إذا لم نجد'**
  String ludoMmCountdownHint(Object seconds);

  /// No description provided for @ludoMmFilledByBots.
  ///
  /// In ar, this message translates to:
  /// **'اكتمل العدد ببوتات احترافية'**
  String get ludoMmFilledByBots;

  /// No description provided for @ludoMmMatchFound.
  ///
  /// In ar, this message translates to:
  /// **'تم العثور على المباراة!'**
  String get ludoMmMatchFound;

  /// No description provided for @ludoMmCancel.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء البحث'**
  String get ludoMmCancel;

  /// No description provided for @ludoMmStarting.
  ///
  /// In ar, this message translates to:
  /// **'تبدأ المباراة…'**
  String get ludoMmStarting;

  /// No description provided for @ludoMmFoundCount.
  ///
  /// In ar, this message translates to:
  /// **'{found}/{total} لاعبين'**
  String ludoMmFoundCount(Object found, Object total);

  /// No description provided for @ludoMode1v1.
  ///
  /// In ar, this message translates to:
  /// **'خصم واحد (١ ضد ١)'**
  String get ludoMode1v1;

  /// No description provided for @ludoMode1v1Sub.
  ///
  /// In ar, this message translates to:
  /// **'مباراة سريعة بهوية مجهولة'**
  String get ludoMode1v1Sub;

  /// No description provided for @ludoMode4Party.
  ///
  /// In ar, this message translates to:
  /// **'حفلة من ٤'**
  String get ludoMode4Party;

  /// No description provided for @ludoMode4PartySub.
  ///
  /// In ar, this message translates to:
  /// **'ابحث عن ٣ خصوم • نكمل ببوتات'**
  String get ludoMode4PartySub;

  /// No description provided for @ludoLobbyHowToPlay.
  ///
  /// In ar, this message translates to:
  /// **'كيف تلعب'**
  String get ludoLobbyHowToPlay;

  /// No description provided for @ludoRule1.
  ///
  /// In ar, this message translates to:
  /// **'ارمِ النرد، اخرج بستّة، اوصل ٤ قطع للمركز'**
  String get ludoRule1;

  /// No description provided for @ludoRule2.
  ///
  /// In ar, this message translates to:
  /// **'٤ قدرات خارقة في الطريق: 🚀 ❄ 🌀 🌪'**
  String get ludoRule2;

  /// No description provided for @ludoRule3.
  ///
  /// In ar, this message translates to:
  /// **'أكل الخصم يمنحك دوراً إضافياً'**
  String get ludoRule3;

  /// No description provided for @ludoRule4.
  ///
  /// In ar, this message translates to:
  /// **'النجوم خانات آمنة • القدرات تتبدّل كل ٣ رميات'**
  String get ludoRule4;

  /// No description provided for @rpsGuessExplain.
  ///
  /// In ar, this message translates to:
  /// **'خمّن ما سيختاره خصمك — تخمين صحيح = نقطة إضافية مع نقطة الفوز بالجولة!'**
  String get rpsGuessExplain;

  /// No description provided for @rateEnjoyTitle.
  ///
  /// In ar, this message translates to:
  /// **'تستمتع بصارحني؟'**
  String get rateEnjoyTitle;

  /// No description provided for @rateEnjoyBody.
  ///
  /// In ar, this message translates to:
  /// **'تقييمك يساعد صارحني على النمو 💜'**
  String get rateEnjoyBody;

  /// No description provided for @rateLove.
  ///
  /// In ar, this message translates to:
  /// **'أحبّه 😍'**
  String get rateLove;

  /// No description provided for @rateMeh.
  ///
  /// In ar, this message translates to:
  /// **'يمكن أن يكون أفضل'**
  String get rateMeh;

  /// No description provided for @rateLater.
  ///
  /// In ar, this message translates to:
  /// **'لاحقاً'**
  String get rateLater;

  /// No description provided for @rateFeedbackTitle.
  ///
  /// In ar, this message translates to:
  /// **'كيف يمكننا التحسين؟'**
  String get rateFeedbackTitle;

  /// No description provided for @rateFeedbackHint.
  ///
  /// In ar, this message translates to:
  /// **'اكتب ملاحظتك…'**
  String get rateFeedbackHint;

  /// No description provided for @rateSend.
  ///
  /// In ar, this message translates to:
  /// **'إرسال'**
  String get rateSend;

  /// No description provided for @rateThanks.
  ///
  /// In ar, this message translates to:
  /// **'شكراً لملاحظتك! 💜'**
  String get rateThanks;

  /// No description provided for @fieldRequired.
  ///
  /// In ar, this message translates to:
  /// **'هذا الحقل مطلوب'**
  String get fieldRequired;

  /// No description provided for @errorInvalidCredentials.
  ///
  /// In ar, this message translates to:
  /// **'بيانات الدخول غير صحيحة'**
  String get errorInvalidCredentials;

  /// No description provided for @errorServerUnreachable.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر الاتصال بالخادم'**
  String get errorServerUnreachable;

  /// No description provided for @errorConnectionLost.
  ///
  /// In ar, this message translates to:
  /// **'انقطع الاتصال'**
  String get errorConnectionLost;

  /// No description provided for @errorUnexpected.
  ///
  /// In ar, this message translates to:
  /// **'حدث خطأ غير متوقع'**
  String get errorUnexpected;

  /// No description provided for @loginUsernameHint.
  ///
  /// In ar, this message translates to:
  /// **'مثلاً: ssarhny'**
  String get loginUsernameHint;

  /// No description provided for @loginSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'سجّل دخولك للمتابعة في صارحني'**
  String get loginSubtitle;

  /// No description provided for @registerAgeConfirmError.
  ///
  /// In ar, this message translates to:
  /// **'يجب تأكيد بلوغك ١٨ سنة فأكثر'**
  String get registerAgeConfirmError;

  /// No description provided for @registerTermsError.
  ///
  /// In ar, this message translates to:
  /// **'يجب الموافقة على الشروط'**
  String get registerTermsError;

  /// No description provided for @registerUsernameTaken.
  ///
  /// In ar, this message translates to:
  /// **'اسم المستخدم محجوز'**
  String get registerUsernameTaken;

  /// No description provided for @registerUsernameFormat.
  ///
  /// In ar, this message translates to:
  /// **'حروف لاتينية وأرقام وشرطة سفلية فقط'**
  String get registerUsernameFormat;

  /// No description provided for @registerUsernameInvalid.
  ///
  /// In ar, this message translates to:
  /// **'اسم المستخدم غير صالح'**
  String get registerUsernameInvalid;

  /// No description provided for @registerEmailTaken.
  ///
  /// In ar, this message translates to:
  /// **'البريد مستخدم بالفعل'**
  String get registerEmailTaken;

  /// No description provided for @registerEmailInvalid.
  ///
  /// In ar, this message translates to:
  /// **'البريد غير صالح'**
  String get registerEmailInvalid;

  /// No description provided for @registerPasswordWeak.
  ///
  /// In ar, this message translates to:
  /// **'كلمة المرور قصيرة أو غير متطابقة'**
  String get registerPasswordWeak;

  /// No description provided for @registerSexRequired.
  ///
  /// In ar, this message translates to:
  /// **'اختر الجنس'**
  String get registerSexRequired;

  /// No description provided for @registerUsernameMin.
  ///
  /// In ar, this message translates to:
  /// **'الحد الأدنى ٣ أحرف'**
  String get registerUsernameMin;

  /// No description provided for @registerUsernameReserved.
  ///
  /// In ar, this message translates to:
  /// **'اسم محجوز'**
  String get registerUsernameReserved;

  /// No description provided for @registerEmailInvalidShort.
  ///
  /// In ar, this message translates to:
  /// **'بريد غير صالح'**
  String get registerEmailInvalidShort;

  /// No description provided for @registerPasswordMin.
  ///
  /// In ar, this message translates to:
  /// **'الحد الأدنى ٨ أحرف'**
  String get registerPasswordMin;

  /// No description provided for @registerPasswordMismatch.
  ///
  /// In ar, this message translates to:
  /// **'لا تتطابق مع كلمة المرور'**
  String get registerPasswordMismatch;

  /// No description provided for @registerJoinTitle.
  ///
  /// In ar, this message translates to:
  /// **'انضم إلى صارحني'**
  String get registerJoinTitle;

  /// No description provided for @registerJoinSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'مساحة للتعبير الأصيل عن الذات — للبالغين فقط'**
  String get registerJoinSubtitle;

  /// No description provided for @registerDisplayName.
  ///
  /// In ar, this message translates to:
  /// **'الاسم المعروض'**
  String get registerDisplayName;

  /// No description provided for @registerNameMin.
  ///
  /// In ar, this message translates to:
  /// **'الحد الأدنى حرفان'**
  String get registerNameMin;

  /// No description provided for @registerUsernameHint.
  ///
  /// In ar, this message translates to:
  /// **'مثال: amal_x'**
  String get registerUsernameHint;

  /// No description provided for @registerPasswordConfirm.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد كلمة المرور'**
  String get registerPasswordConfirm;

  /// No description provided for @registerAgeConfirm.
  ///
  /// In ar, this message translates to:
  /// **'أؤكّد أنّ عمري ١٨ سنة فأكثر'**
  String get registerAgeConfirm;

  /// No description provided for @registerAdultsOnly.
  ///
  /// In ar, this message translates to:
  /// **'صارحني مساحة للبالغين فقط'**
  String get registerAdultsOnly;

  /// No description provided for @registerAgreeTerms.
  ///
  /// In ar, this message translates to:
  /// **'أوافق على شروط الاستخدام وسياسة الخصوصية'**
  String get registerAgreeTerms;

  /// No description provided for @registerHaveAccount.
  ///
  /// In ar, this message translates to:
  /// **'لديك حساب؟'**
  String get registerHaveAccount;

  /// No description provided for @registerSignInCta.
  ///
  /// In ar, this message translates to:
  /// **'سجّل دخولك'**
  String get registerSignInCta;

  /// No description provided for @registerGender.
  ///
  /// In ar, this message translates to:
  /// **'النوع'**
  String get registerGender;

  /// No description provided for @registerGenderMale.
  ///
  /// In ar, this message translates to:
  /// **'ذكر'**
  String get registerGenderMale;

  /// No description provided for @registerGenderFemale.
  ///
  /// In ar, this message translates to:
  /// **'أنثى'**
  String get registerGenderFemale;

  /// No description provided for @forgotTitle.
  ///
  /// In ar, this message translates to:
  /// **'استعادة كلمة المرور'**
  String get forgotTitle;

  /// No description provided for @forgotInstructions.
  ///
  /// In ar, this message translates to:
  /// **'أدخل بريدك المسجَّل، وسنرسل لك رابطاً لإعادة تعيين كلمة المرور خلال ساعة واحدة.'**
  String get forgotInstructions;

  /// No description provided for @forgotSendLink.
  ///
  /// In ar, this message translates to:
  /// **'إرسال الرابط'**
  String get forgotSendLink;

  /// No description provided for @forgotBackToLogin.
  ///
  /// In ar, this message translates to:
  /// **'عودة لتسجيل الدخول'**
  String get forgotBackToLogin;

  /// No description provided for @forgotCheckEmailTitle.
  ///
  /// In ar, this message translates to:
  /// **'تحقّق من بريدك'**
  String get forgotCheckEmailTitle;

  /// No description provided for @forgotEmailSentBody.
  ///
  /// In ar, this message translates to:
  /// **'لو هذا البريد مسجَّل، أرسلنا رابط الاستعادة إلى'**
  String get forgotEmailSentBody;

  /// No description provided for @forgotCheckSpamHint.
  ///
  /// In ar, this message translates to:
  /// **'تفقّد صندوق الرسائل (و\"غير المرغوب فيه\" أحياناً)'**
  String get forgotCheckSpamHint;

  /// No description provided for @resetLinkExpired.
  ///
  /// In ar, this message translates to:
  /// **'الرابط منتهي الصلاحية أو غير صالح'**
  String get resetLinkExpired;

  /// No description provided for @resetTitle.
  ///
  /// In ar, this message translates to:
  /// **'تعيين كلمة مرور جديدة'**
  String get resetTitle;

  /// No description provided for @resetHeading.
  ///
  /// In ar, this message translates to:
  /// **'كلمة مرور جديدة'**
  String get resetHeading;

  /// No description provided for @resetSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'اختر كلمة مرور قوية جديدة لحسابك.'**
  String get resetSubtitle;

  /// No description provided for @resetPasswordMismatch.
  ///
  /// In ar, this message translates to:
  /// **'لا تتطابق'**
  String get resetPasswordMismatch;

  /// No description provided for @resetDoneTitle.
  ///
  /// In ar, this message translates to:
  /// **'تم تحديث كلمة المرور'**
  String get resetDoneTitle;

  /// No description provided for @resetDoneBody.
  ///
  /// In ar, this message translates to:
  /// **'يمكنك الآن تسجيل الدخول بكلمة المرور الجديدة.'**
  String get resetDoneBody;

  /// No description provided for @resetGoToLogin.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الدخول'**
  String get resetGoToLogin;

  /// No description provided for @diagnosticsTitle.
  ///
  /// In ar, this message translates to:
  /// **'تشخيص الاتصال'**
  String get diagnosticsTitle;

  /// No description provided for @diagnosticsEnvStatus.
  ///
  /// In ar, this message translates to:
  /// **'حالة .env'**
  String get diagnosticsEnvStatus;

  /// No description provided for @diagnosticsConnectionStatus.
  ///
  /// In ar, this message translates to:
  /// **'حالة الاتصال'**
  String get diagnosticsConnectionStatus;

  /// No description provided for @diagnosticsHint.
  ///
  /// In ar, this message translates to:
  /// **'اضغط \"اختبر الاتصال\" لرؤية ما يحصل عند الاتصال بالخادم.'**
  String get diagnosticsHint;

  /// No description provided for @diagnosticsTestButton.
  ///
  /// In ar, this message translates to:
  /// **'اختبر الاتصال'**
  String get diagnosticsTestButton;

  /// No description provided for @feedSearchTooltip.
  ///
  /// In ar, this message translates to:
  /// **'بحث'**
  String get feedSearchTooltip;

  /// No description provided for @feedEmptyFollowingTitle.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد منشورات بعد'**
  String get feedEmptyFollowingTitle;

  /// No description provided for @feedEmptySectionTitle.
  ///
  /// In ar, this message translates to:
  /// **'لا يوجد شيء في هذا القسم'**
  String get feedEmptySectionTitle;

  /// No description provided for @feedEmptyFollowingSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'تابع أشخاص لتشاهد منشوراتهم'**
  String get feedEmptyFollowingSubtitle;

  /// No description provided for @feedEmptySectionSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'كن أول من ينشر شيئاً ⚡'**
  String get feedEmptySectionSubtitle;

  /// No description provided for @feedScopeFollowing.
  ///
  /// In ar, this message translates to:
  /// **'شاهد متابعيك'**
  String get feedScopeFollowing;

  /// No description provided for @feedScopeGlobal.
  ///
  /// In ar, this message translates to:
  /// **'شاهد العالم'**
  String get feedScopeGlobal;

  /// No description provided for @feedCrystalBadge.
  ///
  /// In ar, this message translates to:
  /// **'✦ متبلور'**
  String get feedCrystalBadge;

  /// No description provided for @feedQuestionFromAnonymous.
  ///
  /// In ar, this message translates to:
  /// **'سؤال من مجهول'**
  String get feedQuestionFromAnonymous;

  /// No description provided for @feedQuestionFrom.
  ///
  /// In ar, this message translates to:
  /// **'سؤال من'**
  String get feedQuestionFrom;

  /// No description provided for @feedUnsave.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء الحفظ'**
  String get feedUnsave;

  /// No description provided for @feedSave.
  ///
  /// In ar, this message translates to:
  /// **'حفظ'**
  String get feedSave;

  /// No description provided for @feedShareFooter.
  ///
  /// In ar, this message translates to:
  /// **'— من صارحني'**
  String get feedShareFooter;

  /// No description provided for @feedDeleteTitle.
  ///
  /// In ar, this message translates to:
  /// **'حذف المنشور'**
  String get feedDeleteTitle;

  /// No description provided for @feedDeleteBody.
  ///
  /// In ar, this message translates to:
  /// **'سيُحذف منشورك نهائياً ولن يظهر للآخرين. هل أنت متأكد؟'**
  String get feedDeleteBody;

  /// No description provided for @feedDeleteSuccess.
  ///
  /// In ar, this message translates to:
  /// **'تم حذف المنشور'**
  String get feedDeleteSuccess;

  /// No description provided for @feedDeleteFailed.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر الحذف'**
  String get feedDeleteFailed;

  /// No description provided for @feedTimeNow.
  ///
  /// In ar, this message translates to:
  /// **'الآن'**
  String get feedTimeNow;

  /// No description provided for @feedTimeAgo.
  ///
  /// In ar, this message translates to:
  /// **'قبل'**
  String get feedTimeAgo;

  /// No description provided for @feedTimeMinutes.
  ///
  /// In ar, this message translates to:
  /// **'قبل {n} د'**
  String feedTimeMinutes(Object n);

  /// No description provided for @feedTimeHours.
  ///
  /// In ar, this message translates to:
  /// **'قبل {n} س'**
  String feedTimeHours(Object n);

  /// No description provided for @feedTimeDays.
  ///
  /// In ar, this message translates to:
  /// **'قبل {n} يوم'**
  String feedTimeDays(Object n);

  /// No description provided for @feedTimeSeconds.
  ///
  /// In ar, this message translates to:
  /// **'قبل {n} ث'**
  String feedTimeSeconds(Object n);

  /// No description provided for @feedTimeWeeks.
  ///
  /// In ar, this message translates to:
  /// **'قبل {n} أسبوع'**
  String feedTimeWeeks(Object n);

  /// No description provided for @feedTimeMonths.
  ///
  /// In ar, this message translates to:
  /// **'قبل {n} شهر'**
  String feedTimeMonths(Object n);

  /// No description provided for @feedTimeYears.
  ///
  /// In ar, this message translates to:
  /// **'قبل {n} سنة'**
  String feedTimeYears(Object n);

  /// No description provided for @sectionAll.
  ///
  /// In ar, this message translates to:
  /// **'الكل'**
  String get sectionAll;

  /// No description provided for @sectionMoments.
  ///
  /// In ar, this message translates to:
  /// **'لحظات'**
  String get sectionMoments;

  /// No description provided for @sectionFaces.
  ///
  /// In ar, this message translates to:
  /// **'صور'**
  String get sectionFaces;

  /// No description provided for @sectionMinds.
  ///
  /// In ar, this message translates to:
  /// **'أفكار'**
  String get sectionMinds;

  /// No description provided for @sectionAnswers.
  ///
  /// In ar, this message translates to:
  /// **'أجوبة'**
  String get sectionAnswers;

  /// No description provided for @ludoTitle.
  ///
  /// In ar, this message translates to:
  /// **'لودو'**
  String get ludoTitle;

  /// No description provided for @ludoCustomizeSub.
  ///
  /// In ar, this message translates to:
  /// **'الطاولات والفرسان — خصّص شكلك'**
  String get ludoCustomizeSub;

  /// No description provided for @ludoPlayType.
  ///
  /// In ar, this message translates to:
  /// **'نوع اللعب'**
  String get ludoPlayType;

  /// No description provided for @ludoClassic.
  ///
  /// In ar, this message translates to:
  /// **'عادي'**
  String get ludoClassic;

  /// No description provided for @ludoClassicSub.
  ///
  /// In ar, this message translates to:
  /// **'لودو كلاسيكي'**
  String get ludoClassicSub;

  /// No description provided for @ludoPowers.
  ///
  /// In ar, this message translates to:
  /// **'قدرات خاصة'**
  String get ludoPowers;

  /// No description provided for @ludoPowersSub.
  ///
  /// In ar, this message translates to:
  /// **'صاروخ • تجميد • بوابة • إعصار'**
  String get ludoPowersSub;

  /// No description provided for @ludoPlay.
  ///
  /// In ar, this message translates to:
  /// **'العب'**
  String get ludoPlay;

  /// No description provided for @ludoRoyalSub.
  ///
  /// In ar, this message translates to:
  /// **'لودو ملكي — ٤ لاعبين، نرد وقدرات على اللوحة'**
  String get ludoRoyalSub;

  /// No description provided for @ludoBoardsKnights.
  ///
  /// In ar, this message translates to:
  /// **'الطاولات والفرسان'**
  String get ludoBoardsKnights;

  /// No description provided for @ludoPickBoard.
  ///
  /// In ar, this message translates to:
  /// **'اختر الطاولة'**
  String get ludoPickBoard;

  /// No description provided for @ludoPickKnight.
  ///
  /// In ar, this message translates to:
  /// **'اختر الفرسان'**
  String get ludoPickKnight;

  /// No description provided for @ludoAutoPlayed.
  ///
  /// In ar, this message translates to:
  /// **'انتهى وقتك — لعبنا بدالك'**
  String get ludoAutoPlayed;

  /// No description provided for @ludoYouWon.
  ///
  /// In ar, this message translates to:
  /// **'🎉 فزت!'**
  String get ludoYouWon;

  /// No description provided for @ludoPlayerWon.
  ///
  /// In ar, this message translates to:
  /// **'{name} فاز'**
  String ludoPlayerWon(Object name);

  /// No description provided for @ludoWinSub.
  ///
  /// In ar, this message translates to:
  /// **'أوصلت أحجارك الأربعة للمركز'**
  String get ludoWinSub;

  /// No description provided for @ludoLoseSub.
  ///
  /// In ar, this message translates to:
  /// **'حظ أوفر في الجولة القادمة'**
  String get ludoLoseSub;

  /// No description provided for @ludoEnded.
  ///
  /// In ar, this message translates to:
  /// **'انتهت'**
  String get ludoEnded;

  /// No description provided for @ludoPlayerTurn.
  ///
  /// In ar, this message translates to:
  /// **'دور {name}'**
  String ludoPlayerTurn(Object name);

  /// No description provided for @ludoChat.
  ///
  /// In ar, this message translates to:
  /// **'دردشة'**
  String get ludoChat;

  /// No description provided for @ludoExit.
  ///
  /// In ar, this message translates to:
  /// **'خروج'**
  String get ludoExit;

  /// No description provided for @ludoEvCapture.
  ///
  /// In ar, this message translates to:
  /// **'أكلت حجراً!'**
  String get ludoEvCapture;

  /// No description provided for @ludoEvTornado.
  ///
  /// In ar, this message translates to:
  /// **'إعصار!'**
  String get ludoEvTornado;

  /// No description provided for @ludoEvRocket.
  ///
  /// In ar, this message translates to:
  /// **'صاروخ! +{n}'**
  String ludoEvRocket(Object n);

  /// No description provided for @ludoEvFreeze.
  ///
  /// In ar, this message translates to:
  /// **'تجمّدت!'**
  String get ludoEvFreeze;

  /// No description provided for @ludoEvPortal.
  ///
  /// In ar, this message translates to:
  /// **'بوابة! {n}'**
  String ludoEvPortal(Object n);

  /// No description provided for @ludoEvShuffle.
  ///
  /// In ar, this message translates to:
  /// **'تبدّلت القدرات'**
  String get ludoEvShuffle;

  /// No description provided for @ludoColorGold.
  ///
  /// In ar, this message translates to:
  /// **'الذهبي'**
  String get ludoColorGold;

  /// No description provided for @ludoColorBlue.
  ///
  /// In ar, this message translates to:
  /// **'الأزرق'**
  String get ludoColorBlue;

  /// No description provided for @ludoColorPurple.
  ///
  /// In ar, this message translates to:
  /// **'البنفسجي'**
  String get ludoColorPurple;

  /// No description provided for @ludoColorYou.
  ///
  /// In ar, this message translates to:
  /// **'أنت'**
  String get ludoColorYou;

  /// No description provided for @ludoSkinRoyal.
  ///
  /// In ar, this message translates to:
  /// **'الملكية الذهبية'**
  String get ludoSkinRoyal;

  /// No description provided for @ludoSkinNeon.
  ///
  /// In ar, this message translates to:
  /// **'نيون سايبر'**
  String get ludoSkinNeon;

  /// No description provided for @ludoSkinArabian.
  ///
  /// In ar, this message translates to:
  /// **'ليالٍ عربية'**
  String get ludoSkinArabian;

  /// No description provided for @ludoKnightClassic.
  ///
  /// In ar, this message translates to:
  /// **'كلاسيك'**
  String get ludoKnightClassic;

  /// No description provided for @ludoKnightKnight.
  ///
  /// In ar, this message translates to:
  /// **'الفارس'**
  String get ludoKnightKnight;

  /// No description provided for @ludoKnightSorcerer.
  ///
  /// In ar, this message translates to:
  /// **'الساحر'**
  String get ludoKnightSorcerer;

  /// No description provided for @ludoKnightCrown.
  ///
  /// In ar, this message translates to:
  /// **'التاج'**
  String get ludoKnightCrown;

  /// No description provided for @ludoHubSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'لودو ملكي — ٤ لاعبين بقدرات على اللوحة 🚀❄️🌀🌪'**
  String get ludoHubSubtitle;

  /// No description provided for @ludoHubTag.
  ///
  /// In ar, this message translates to:
  /// **'جديد'**
  String get ludoHubTag;

  /// No description provided for @inboxAppBarTitle.
  ///
  /// In ar, this message translates to:
  /// **'الصندوق'**
  String get inboxAppBarTitle;

  /// No description provided for @inboxEmptyTitle.
  ///
  /// In ar, this message translates to:
  /// **'الصندوق فارغ'**
  String get inboxEmptyTitle;

  /// No description provided for @inboxEmptySubtitle.
  ///
  /// In ar, this message translates to:
  /// **'الرسائل المجهولة ستظهر هنا'**
  String get inboxEmptySubtitle;

  /// No description provided for @inboxMarkedRead.
  ///
  /// In ar, this message translates to:
  /// **'تم وضعها كمقروءة'**
  String get inboxMarkedRead;

  /// No description provided for @inboxUpdateFailed.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر التحديث'**
  String get inboxUpdateFailed;

  /// No description provided for @inboxDeleted.
  ///
  /// In ar, this message translates to:
  /// **'تم الحذف'**
  String get inboxDeleted;

  /// No description provided for @inboxDeleteFailed.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر الحذف'**
  String get inboxDeleteFailed;

  /// No description provided for @inboxReported.
  ///
  /// In ar, this message translates to:
  /// **'تم الإبلاغ — سنراجعها'**
  String get inboxReported;

  /// No description provided for @inboxReportFailed.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر الإبلاغ'**
  String get inboxReportFailed;

  /// No description provided for @inboxAnonymous.
  ///
  /// In ar, this message translates to:
  /// **'مجهول'**
  String get inboxAnonymous;

  /// No description provided for @inboxReplyWithPost.
  ///
  /// In ar, this message translates to:
  /// **'الرد بمنشور'**
  String get inboxReplyWithPost;

  /// No description provided for @inboxAnswered.
  ///
  /// In ar, this message translates to:
  /// **'مُجاب'**
  String get inboxAnswered;

  /// No description provided for @inboxReportTooltip.
  ///
  /// In ar, this message translates to:
  /// **'إبلاغ'**
  String get inboxReportTooltip;

  /// No description provided for @inboxAnswerEmptyError.
  ///
  /// In ar, this message translates to:
  /// **'اكتب ردك أولاً'**
  String get inboxAnswerEmptyError;

  /// No description provided for @inboxReplyPublished.
  ///
  /// In ar, this message translates to:
  /// **'تم نشر الرد ✨'**
  String get inboxReplyPublished;

  /// No description provided for @inboxSessionExpired.
  ///
  /// In ar, this message translates to:
  /// **'سجّل دخولك من جديد'**
  String get inboxSessionExpired;

  /// No description provided for @inboxRateLimited.
  ///
  /// In ar, this message translates to:
  /// **'مهلاً قليلاً، أعد المحاولة بعد دقيقة'**
  String get inboxRateLimited;

  /// No description provided for @inboxConnectionFailed.
  ///
  /// In ar, this message translates to:
  /// **'فشل الاتصال —'**
  String get inboxConnectionFailed;

  /// No description provided for @inboxYourReplyLabel.
  ///
  /// In ar, this message translates to:
  /// **'ردك (سيُنشر كمنشور 🎨)'**
  String get inboxYourReplyLabel;

  /// No description provided for @inboxReplyHint.
  ///
  /// In ar, this message translates to:
  /// **'اكتب ردك…'**
  String get inboxReplyHint;

  /// No description provided for @inboxHideLayer3.
  ///
  /// In ar, this message translates to:
  /// **'إخفاء الطبقة ٣'**
  String get inboxHideLayer3;

  /// No description provided for @inboxAddLayer3.
  ///
  /// In ar, this message translates to:
  /// **'إضافة طبقة ٣ — تأمل'**
  String get inboxAddLayer3;

  /// No description provided for @inboxLayer3Hint.
  ///
  /// In ar, this message translates to:
  /// **'تأمّلك (اختياري)'**
  String get inboxLayer3Hint;

  /// No description provided for @inboxPublishReply.
  ///
  /// In ar, this message translates to:
  /// **'نشر الرد'**
  String get inboxPublishReply;

  /// No description provided for @mirrorsNewMirror.
  ///
  /// In ar, this message translates to:
  /// **'مرآة جديدة'**
  String get mirrorsNewMirror;

  /// No description provided for @mirrorsEmptyTitle.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد مرايا بعد'**
  String get mirrorsEmptyTitle;

  /// No description provided for @mirrorsEmptySubtitle.
  ///
  /// In ar, this message translates to:
  /// **'ابدأ بنشر المرايا — اطرح سؤالاً ودَع الناس يجيبون بإخلاص'**
  String get mirrorsEmptySubtitle;

  /// No description provided for @mirrorsBadge.
  ///
  /// In ar, this message translates to:
  /// **'🪞 مرآة'**
  String get mirrorsBadge;

  /// No description provided for @mirrorsResponsesSuffix.
  ///
  /// In ar, this message translates to:
  /// **'ردًا'**
  String get mirrorsResponsesSuffix;

  /// No description provided for @mirrorsCopyLink.
  ///
  /// In ar, this message translates to:
  /// **'نسخ الرابط'**
  String get mirrorsCopyLink;

  /// No description provided for @mirrorsShareMessage.
  ///
  /// In ar, this message translates to:
  /// **'شارك معي إجابتك على هذه المرآة:'**
  String get mirrorsShareMessage;

  /// No description provided for @mirrorsShareSubject.
  ///
  /// In ar, this message translates to:
  /// **'صارحني — مرآة'**
  String get mirrorsShareSubject;

  /// No description provided for @mirrorsShareFailed.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر فتح المشاركة'**
  String get mirrorsShareFailed;

  /// No description provided for @mirrorsQuestionLabel.
  ///
  /// In ar, this message translates to:
  /// **'سؤال المرآة'**
  String get mirrorsQuestionLabel;

  /// No description provided for @mirrorsCreateHint.
  ///
  /// In ar, this message translates to:
  /// **'سؤال موجَّه يقصد كشف الذات — الردود مجهولة وتبني سحابة كلمات.'**
  String get mirrorsCreateHint;

  /// No description provided for @mirrorsQuestionHint.
  ///
  /// In ar, this message translates to:
  /// **'مثلاً: ما الذي يجعلك فخوراً بنفسك؟'**
  String get mirrorsQuestionHint;

  /// No description provided for @mirrorsCreateButton.
  ///
  /// In ar, this message translates to:
  /// **'إنشاء المرآة'**
  String get mirrorsCreateButton;

  /// No description provided for @mirrorsCreated.
  ///
  /// In ar, this message translates to:
  /// **'تم إنشاء المرآة'**
  String get mirrorsCreated;

  /// No description provided for @mirrorsCreateFailed.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر الإنشاء'**
  String get mirrorsCreateFailed;

  /// No description provided for @mirrorsLoginToRespond.
  ///
  /// In ar, this message translates to:
  /// **'سجّل دخولك للرد على المرآة'**
  String get mirrorsLoginToRespond;

  /// No description provided for @mirrorsRateLimit.
  ///
  /// In ar, this message translates to:
  /// **'لقد رددت كثيراً مؤخراً — انتظر قليلاً'**
  String get mirrorsRateLimit;

  /// No description provided for @mirrorsSendFailed.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر الإرسال'**
  String get mirrorsSendFailed;

  /// No description provided for @mirrorsBadgeShort.
  ///
  /// In ar, this message translates to:
  /// **'مرآة'**
  String get mirrorsBadgeShort;

  /// No description provided for @mirrorsQuestionTitle.
  ///
  /// In ar, this message translates to:
  /// **'السؤال'**
  String get mirrorsQuestionTitle;

  /// No description provided for @mirrorsResponseHint.
  ///
  /// In ar, this message translates to:
  /// **'اكتب ردك بصدق — هويتك لن تظهر'**
  String get mirrorsResponseHint;

  /// No description provided for @mirrorsAnonymousNote.
  ///
  /// In ar, this message translates to:
  /// **'يمكنك الرد بدون تسجيل — هويتك لن تظهر مطلقاً'**
  String get mirrorsAnonymousNote;

  /// No description provided for @mirrorsSendResponse.
  ///
  /// In ar, this message translates to:
  /// **'أرسل ردي'**
  String get mirrorsSendResponse;

  /// No description provided for @mirrorsFrom.
  ///
  /// In ar, this message translates to:
  /// **'مرآة من'**
  String get mirrorsFrom;

  /// No description provided for @mirrorsSentTitle.
  ///
  /// In ar, this message translates to:
  /// **'تم إرسال ردك'**
  String get mirrorsSentTitle;

  /// No description provided for @mirrorsSentBody.
  ///
  /// In ar, this message translates to:
  /// **'كلماتك ستضيف لسحابة الكلمات التي يراها صاحب المرآة. شكراً لصدقك 🌙'**
  String get mirrorsSentBody;

  /// No description provided for @mirrorsBackHome.
  ///
  /// In ar, this message translates to:
  /// **'عودة للرئيسية'**
  String get mirrorsBackHome;

  /// No description provided for @postTitle.
  ///
  /// In ar, this message translates to:
  /// **'منشور'**
  String get postTitle;

  /// No description provided for @postReplyHint.
  ///
  /// In ar, this message translates to:
  /// **'اكتب ردّك…'**
  String get postReplyHint;

  /// No description provided for @postMicPermission.
  ///
  /// In ar, this message translates to:
  /// **'يلزم إذن الميكروفون'**
  String get postMicPermission;

  /// No description provided for @postRecordStartFailed.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر بدء التسجيل'**
  String get postRecordStartFailed;

  /// No description provided for @postImagePickFailed.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر اختيار الصورة'**
  String get postImagePickFailed;

  /// No description provided for @postSlowDownRetry.
  ///
  /// In ar, this message translates to:
  /// **'تمهّل قليلاً ثم أعد المحاولة'**
  String get postSlowDownRetry;

  /// No description provided for @postSendFailed.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر الإرسال'**
  String get postSendFailed;

  /// No description provided for @postTooltipImage.
  ///
  /// In ar, this message translates to:
  /// **'صورة'**
  String get postTooltipImage;

  /// No description provided for @postTooltipVoice.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل صوتي'**
  String get postTooltipVoice;

  /// No description provided for @postVoiceRecording.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل صوتي'**
  String get postVoiceRecording;

  /// No description provided for @postSecondsShort.
  ///
  /// In ar, this message translates to:
  /// **'ث'**
  String get postSecondsShort;

  /// No description provided for @postReplySent.
  ///
  /// In ar, this message translates to:
  /// **'تم الإرسال 🌙'**
  String get postReplySent;

  /// No description provided for @postLoginToReply.
  ///
  /// In ar, this message translates to:
  /// **'سجّل دخولك للرد'**
  String get postLoginToReply;

  /// No description provided for @postSlowDownBeforeSend.
  ///
  /// In ar, this message translates to:
  /// **'تمهّل قليلاً قبل الإرسال'**
  String get postSlowDownBeforeSend;

  /// No description provided for @postRepliesTitle.
  ///
  /// In ar, this message translates to:
  /// **'الردود'**
  String get postRepliesTitle;

  /// No description provided for @postRepliesLoadFailed.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر تحميل الردود'**
  String get postRepliesLoadFailed;

  /// No description provided for @postRepliesEmpty.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد ردود بعد. كن أوّل من يفتح حواراً 🌙'**
  String get postRepliesEmpty;

  /// No description provided for @postLoadMore.
  ///
  /// In ar, this message translates to:
  /// **'تحميل المزيد'**
  String get postLoadMore;

  /// No description provided for @postAnonymous.
  ///
  /// In ar, this message translates to:
  /// **'مجهول'**
  String get postAnonymous;

  /// No description provided for @postWithName.
  ///
  /// In ar, this message translates to:
  /// **'باسمي'**
  String get postWithName;

  /// No description provided for @postDeleteReplyTitle.
  ///
  /// In ar, this message translates to:
  /// **'حذف الرد'**
  String get postDeleteReplyTitle;

  /// No description provided for @postDeleteReplyConfirmMine.
  ///
  /// In ar, this message translates to:
  /// **'سيختفي ردّك. هل أنت متأكد؟'**
  String get postDeleteReplyConfirmMine;

  /// No description provided for @postDeleteReplyConfirmOther.
  ///
  /// In ar, this message translates to:
  /// **'سيختفي هذا الرد من منشورك.'**
  String get postDeleteReplyConfirmOther;

  /// No description provided for @postDeleted.
  ///
  /// In ar, this message translates to:
  /// **'تم الحذف'**
  String get postDeleted;

  /// No description provided for @postDeleteFailed.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر الحذف'**
  String get postDeleteFailed;

  /// No description provided for @postDeleteCommentTitle.
  ///
  /// In ar, this message translates to:
  /// **'حذف التعليق'**
  String get postDeleteCommentTitle;

  /// No description provided for @postDeleteCommentConfirm.
  ///
  /// In ar, this message translates to:
  /// **'سيُحذف التعليق نهائياً. متابعة؟'**
  String get postDeleteCommentConfirm;

  /// No description provided for @postPublished.
  ///
  /// In ar, this message translates to:
  /// **'تم النشر'**
  String get postPublished;

  /// No description provided for @postLoginToComment.
  ///
  /// In ar, this message translates to:
  /// **'سجّل دخولك للتعليق'**
  String get postLoginToComment;

  /// No description provided for @postPublishFailed.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر النشر'**
  String get postPublishFailed;

  /// No description provided for @postCommentsTitle.
  ///
  /// In ar, this message translates to:
  /// **'التعليقات'**
  String get postCommentsTitle;

  /// No description provided for @postCommentHint.
  ///
  /// In ar, this message translates to:
  /// **'اكتب تعليقاً…'**
  String get postCommentHint;

  /// No description provided for @postCommentsLoadFailed.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر تحميل التعليقات'**
  String get postCommentsLoadFailed;

  /// No description provided for @postCommentsEmpty.
  ///
  /// In ar, this message translates to:
  /// **'كن أول من يعلّق'**
  String get postCommentsEmpty;

  /// No description provided for @profileSessionIncomplete.
  ///
  /// In ar, this message translates to:
  /// **'جلستك غير مكتملة'**
  String get profileSessionIncomplete;

  /// No description provided for @profileSessionIncompleteHint.
  ///
  /// In ar, this message translates to:
  /// **'سجّل دخولك من جديد ليعمل كل شيء بشكل صحيح.'**
  String get profileSessionIncompleteHint;

  /// No description provided for @profileLogoutRelogin.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل خروج وإعادة دخول'**
  String get profileLogoutRelogin;

  /// No description provided for @profileShareMine.
  ///
  /// In ar, this message translates to:
  /// **'مشاركة بروفايلي'**
  String get profileShareMine;

  /// No description provided for @profileThemeLight.
  ///
  /// In ar, this message translates to:
  /// **'الوضع النهاري'**
  String get profileThemeLight;

  /// No description provided for @profileThemeDark.
  ///
  /// In ar, this message translates to:
  /// **'الوضع الليلي'**
  String get profileThemeDark;

  /// No description provided for @profileEmptyActiveTitle.
  ///
  /// In ar, this message translates to:
  /// **'لا يوجد منشور نشط'**
  String get profileEmptyActiveTitle;

  /// No description provided for @profileEmptyActiveSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'أنشئ منشوراً ⚡'**
  String get profileEmptyActiveSubtitle;

  /// No description provided for @profileEmptyMomentsTitle.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد لحظات بعد'**
  String get profileEmptyMomentsTitle;

  /// No description provided for @profileEmptyMomentsSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'شارك لحظة من يومك ⚡'**
  String get profileEmptyMomentsSubtitle;

  /// No description provided for @profileEmptyAnswersTitle.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد أجوبة بعد'**
  String get profileEmptyAnswersTitle;

  /// No description provided for @profileEmptyAnswersSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'ردودك على الرسائل المجهولة ستظهر هنا 🕶️'**
  String get profileEmptyAnswersSubtitle;

  /// No description provided for @profileEmptyCrystalsTitle.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد بلورات بعد'**
  String get profileEmptyCrystalsTitle;

  /// No description provided for @profileEmptyLikesTitle.
  ///
  /// In ar, this message translates to:
  /// **'لم تعجبك أي بلورة بعد'**
  String get profileEmptyLikesTitle;

  /// No description provided for @profileAvatarUpdated.
  ///
  /// In ar, this message translates to:
  /// **'تم تحديث الصورة'**
  String get profileAvatarUpdated;

  /// No description provided for @profileUploadFailed.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر الرفع'**
  String get profileUploadFailed;

  /// No description provided for @profileEditTitle.
  ///
  /// In ar, this message translates to:
  /// **'تعديل البروفايل'**
  String get profileEditTitle;

  /// No description provided for @profileFieldDisplayName.
  ///
  /// In ar, this message translates to:
  /// **'الاسم المعروض'**
  String get profileFieldDisplayName;

  /// No description provided for @profileFieldBio.
  ///
  /// In ar, this message translates to:
  /// **'نبذة'**
  String get profileFieldBio;

  /// No description provided for @profileFieldLocation.
  ///
  /// In ar, this message translates to:
  /// **'الموقع'**
  String get profileFieldLocation;

  /// No description provided for @profileFieldWebsite.
  ///
  /// In ar, this message translates to:
  /// **'الموقع الإلكتروني'**
  String get profileFieldWebsite;

  /// No description provided for @profileSaved.
  ///
  /// In ar, this message translates to:
  /// **'تم الحفظ'**
  String get profileSaved;

  /// No description provided for @profileSaveFailed.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر الحفظ'**
  String get profileSaveFailed;

  /// No description provided for @profileShareAccount.
  ///
  /// In ar, this message translates to:
  /// **'انشر حسابك'**
  String get profileShareAccount;

  /// No description provided for @profilePersona.
  ///
  /// In ar, this message translates to:
  /// **'شخصيتي'**
  String get profilePersona;

  /// No description provided for @profileFollowingCount.
  ///
  /// In ar, this message translates to:
  /// **'أتابع'**
  String get profileFollowingCount;

  /// No description provided for @profileAnswers.
  ///
  /// In ar, this message translates to:
  /// **'أجوبة'**
  String get profileAnswers;

  /// No description provided for @profileBadgeCrystals.
  ///
  /// In ar, this message translates to:
  /// **'بلورات'**
  String get profileBadgeCrystals;

  /// No description provided for @profileBadgeStreak.
  ///
  /// In ar, this message translates to:
  /// **'وهج'**
  String get profileBadgeStreak;

  /// No description provided for @profileBadgeMirrors.
  ///
  /// In ar, this message translates to:
  /// **'مرايا'**
  String get profileBadgeMirrors;

  /// No description provided for @profileTabActiveShort.
  ///
  /// In ar, this message translates to:
  /// **'نشط'**
  String get profileTabActiveShort;

  /// No description provided for @profileTabMoments.
  ///
  /// In ar, this message translates to:
  /// **'لحظات'**
  String get profileTabMoments;

  /// No description provided for @profileTabAnswers.
  ///
  /// In ar, this message translates to:
  /// **'أجوبة'**
  String get profileTabAnswers;

  /// No description provided for @profileTabCrystalsShort.
  ///
  /// In ar, this message translates to:
  /// **'متبلور'**
  String get profileTabCrystalsShort;

  /// No description provided for @profileTabLikesShort.
  ///
  /// In ar, this message translates to:
  /// **'إعجابات'**
  String get profileTabLikesShort;

  /// No description provided for @profileQuickSaved.
  ///
  /// In ar, this message translates to:
  /// **'محفوظاتي'**
  String get profileQuickSaved;

  /// No description provided for @profileQuickPlay.
  ///
  /// In ar, this message translates to:
  /// **'العب وتحدى'**
  String get profileQuickPlay;

  /// No description provided for @profileQuickHelp.
  ///
  /// In ar, this message translates to:
  /// **'المساعدة'**
  String get profileQuickHelp;

  /// No description provided for @profileShareThis.
  ///
  /// In ar, this message translates to:
  /// **'مشاركة هذا البروفايل'**
  String get profileShareThis;

  /// No description provided for @profileBlockUser.
  ///
  /// In ar, this message translates to:
  /// **'حظر هذا المستخدم'**
  String get profileBlockUser;

  /// No description provided for @profileBlockUserBody.
  ///
  /// In ar, this message translates to:
  /// **'لن تستقبل أي رسائل أو منشورات منه، ولن يراك أيضاً. تستطيع إلغاء الحظر لاحقاً من شاشة الإعدادات.'**
  String get profileBlockUserBody;

  /// No description provided for @profileBlocked.
  ///
  /// In ar, this message translates to:
  /// **'تم الحظر'**
  String get profileBlocked;

  /// No description provided for @profileBlockFailed.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر الحظر'**
  String get profileBlockFailed;

  /// No description provided for @profileReportSent.
  ///
  /// In ar, this message translates to:
  /// **'تم إرسال البلاغ — سنراجعه'**
  String get profileReportSent;

  /// No description provided for @profileReport.
  ///
  /// In ar, this message translates to:
  /// **'إبلاغ'**
  String get profileReport;

  /// No description provided for @profileNothingHere.
  ///
  /// In ar, this message translates to:
  /// **'لا يوجد شيء هنا بعد'**
  String get profileNothingHere;

  /// No description provided for @profileFollowingStat.
  ///
  /// In ar, this message translates to:
  /// **'متابَعون'**
  String get profileFollowingStat;

  /// No description provided for @profileActionFailed.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر تنفيذ الطلب'**
  String get profileActionFailed;

  /// No description provided for @profileFollowingState.
  ///
  /// In ar, this message translates to:
  /// **'تتابعه'**
  String get profileFollowingState;

  /// No description provided for @profileFollowAction.
  ///
  /// In ar, this message translates to:
  /// **'تابع'**
  String get profileFollowAction;

  /// No description provided for @profileBadgeHowToGet.
  ///
  /// In ar, this message translates to:
  /// **'كيف تحصل عليها'**
  String get profileBadgeHowToGet;

  /// No description provided for @profileBadgeCrystalsTitle.
  ///
  /// In ar, this message translates to:
  /// **'البلورات ✦'**
  String get profileBadgeCrystalsTitle;

  /// No description provided for @profileBadgeCrystalsLead.
  ///
  /// In ar, this message translates to:
  /// **'البلورات هي منشوراتك التي صمدت ٢٤ ساعة ونالت تفاعلاً صادقاً، فتحوّلت من لحظة عابرة إلى أثر دائم.'**
  String get profileBadgeCrystalsLead;

  /// No description provided for @profileBadgeCrystalsStep1.
  ///
  /// In ar, this message translates to:
  /// **'انشر شيئاً يستحق النقاش — لحظة، صورة، أو فكرة.'**
  String get profileBadgeCrystalsStep1;

  /// No description provided for @profileBadgeCrystalsStep2.
  ///
  /// In ar, this message translates to:
  /// **'كل تفاعل (إعجاب، رد) يرفع جاذبية المنشور.'**
  String get profileBadgeCrystalsStep2;

  /// No description provided for @profileBadgeCrystalsStep3.
  ///
  /// In ar, this message translates to:
  /// **'عند الوصول لعتبة التبلور قبل انتهاء الـ ٢٤ ساعة → يصبح ✦ دائماً ويُحفظ في بلوراتك.'**
  String get profileBadgeCrystalsStep3;

  /// No description provided for @profileBadgeCrystalsStep4.
  ///
  /// In ar, this message translates to:
  /// **'منشورات بدون تفاعل تختفي بهدوء بعد ٢٤ ساعة (هذا ما يجعل البلورة قيّمة).'**
  String get profileBadgeCrystalsStep4;

  /// No description provided for @profileBadgeCrystalsTip.
  ///
  /// In ar, this message translates to:
  /// **'البلورات تظهر للزائر في بروفايلك كدليل على بصمتك. اطرح ما يصمد، لا ما يكثر.'**
  String get profileBadgeCrystalsTip;

  /// No description provided for @profileBadgeStreakTitle.
  ///
  /// In ar, this message translates to:
  /// **'الوهج 🔥'**
  String get profileBadgeStreakTitle;

  /// No description provided for @profileBadgeStreakLead.
  ///
  /// In ar, this message translates to:
  /// **'الوهج هو سلسلة أيامك المتتالية في صارحني. كل يوم تنشر فيه يضيف لومة لشعلتك.'**
  String get profileBadgeStreakLead;

  /// No description provided for @profileBadgeStreakStep1.
  ///
  /// In ar, this message translates to:
  /// **'افتح التطبيق وانشر منشوراً واحداً على الأقل كل ٢٤ ساعة.'**
  String get profileBadgeStreakStep1;

  /// No description provided for @profileBadgeStreakStep2.
  ///
  /// In ar, this message translates to:
  /// **'الوهج يحفظ تسلسلك حتى ٤٨ ساعة كحدّ أقصى للتنفّس.'**
  String get profileBadgeStreakStep2;

  /// No description provided for @profileBadgeStreakStep3.
  ///
  /// In ar, this message translates to:
  /// **'كلما طالت السلسلة كلما أصبح وهجك أنبل وأبرز في مرئيات بروفايلك.'**
  String get profileBadgeStreakStep3;

  /// No description provided for @profileBadgeStreakStep4.
  ///
  /// In ar, this message translates to:
  /// **'كسر السلسلة يصفّر العدّاد — لكن لا يمحو ما بنيته من بلورات.'**
  String get profileBadgeStreakStep4;

  /// No description provided for @profileBadgeStreakTip.
  ///
  /// In ar, this message translates to:
  /// **'الوهج لا يقيس الجودة بل الإخلاص. اكتب قليلاً كل يوم خير من كثير في يوم.'**
  String get profileBadgeStreakTip;

  /// No description provided for @profileBadgeMirrorsTitle.
  ///
  /// In ar, this message translates to:
  /// **'المرايا 🪞'**
  String get profileBadgeMirrorsTitle;

  /// No description provided for @profileBadgeMirrorsLead.
  ///
  /// In ar, this message translates to:
  /// **'المرآة سؤال مفتوح تطرحه ودَع الناس يصفونك من خلاله بإخلاص. تتراكم الإجابات لتشكّل سحابة تعكس كيف يراك من حولك.'**
  String get profileBadgeMirrorsLead;

  /// No description provided for @profileBadgeMirrorsStep1.
  ///
  /// In ar, this message translates to:
  /// **'اضغط على تبويب «المرايا» وأنشئ سؤالاً تأمّلياً (مثل: ما أكثر ما يميّزني؟).'**
  String get profileBadgeMirrorsStep1;

  /// No description provided for @profileBadgeMirrorsStep2.
  ///
  /// In ar, this message translates to:
  /// **'شارك رابط المرآة مع أصدقائك أو على حسابك في تطبيق آخر.'**
  String get profileBadgeMirrorsStep2;

  /// No description provided for @profileBadgeMirrorsStep3.
  ///
  /// In ar, this message translates to:
  /// **'تأتيك الإجابات مجهولة — لا تعرف من قال ماذا، فيقول الناس بصراحة.'**
  String get profileBadgeMirrorsStep3;

  /// No description provided for @profileBadgeMirrorsStep4.
  ///
  /// In ar, this message translates to:
  /// **'كل مرآة تكسبك بادج 🪞 يظهر في بروفايلك ويرفع ثقلك في صارحني.'**
  String get profileBadgeMirrorsStep4;

  /// No description provided for @profileBadgeMirrorsTip.
  ///
  /// In ar, this message translates to:
  /// **'المرايا تعمل أحسن مع أسئلة محدّدة لا فضفاضة. اسأل عمّا تريد فعلاً أن تعرفه.'**
  String get profileBadgeMirrorsTip;

  /// No description provided for @profileSavedTitle.
  ///
  /// In ar, this message translates to:
  /// **'المحفوظات'**
  String get profileSavedTitle;

  /// No description provided for @profileSavedEmptyTitle.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد محفوظات'**
  String get profileSavedEmptyTitle;

  /// No description provided for @profileSavedEmptySubtitle.
  ///
  /// In ar, this message translates to:
  /// **'احفظ منشوراً بالضغط على 🔖 ليظهر هنا'**
  String get profileSavedEmptySubtitle;

  /// No description provided for @profileAnonLoginRequired.
  ///
  /// In ar, this message translates to:
  /// **'سجّل دخولك لإرسال رسالة'**
  String get profileAnonLoginRequired;

  /// No description provided for @profileAnonSent.
  ///
  /// In ar, this message translates to:
  /// **'وصلت رسالتك 🌙'**
  String get profileAnonSent;

  /// No description provided for @profileAnonRateLimited.
  ///
  /// In ar, this message translates to:
  /// **'الكثير من المحاولات — انتظر قليلاً'**
  String get profileAnonRateLimited;

  /// No description provided for @profileAnonSendFailed.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر الإرسال'**
  String get profileAnonSendFailed;

  /// No description provided for @profileAnonTitle.
  ///
  /// In ar, this message translates to:
  /// **'اسأله بهوية مجهولة'**
  String get profileAnonTitle;

  /// No description provided for @profileAnonSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'لن يعرف من أرسل — إلا إذا كشفت عن نفسك'**
  String get profileAnonSubtitle;

  /// No description provided for @profileAnonHint.
  ///
  /// In ar, this message translates to:
  /// **'اكتب سؤالك أو رسالتك…'**
  String get profileAnonHint;

  /// No description provided for @profileAnonSend.
  ///
  /// In ar, this message translates to:
  /// **'أرسل'**
  String get profileAnonSend;

  /// No description provided for @profileLinkCopied.
  ///
  /// In ar, this message translates to:
  /// **'تم نسخ الرابط'**
  String get profileLinkCopied;

  /// No description provided for @articleAppBarTitle.
  ///
  /// In ar, this message translates to:
  /// **'شخصيتي ✨'**
  String get articleAppBarTitle;

  /// No description provided for @articleGenerated.
  ///
  /// In ar, this message translates to:
  /// **'تم إنشاء مقالتك ✨'**
  String get articleGenerated;

  /// No description provided for @articleGenerateFailed.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر الإنشاء'**
  String get articleGenerateFailed;

  /// No description provided for @articleCurrentLabel.
  ///
  /// In ar, this message translates to:
  /// **'مقالتي الحالية'**
  String get articleCurrentLabel;

  /// No description provided for @articleArchiveLabel.
  ///
  /// In ar, this message translates to:
  /// **'الأرشيف · مقالات سابقة ({count})'**
  String articleArchiveLabel(Object count);

  /// No description provided for @articleHeaderTitle.
  ///
  /// In ar, this message translates to:
  /// **'مقالتك الشخصية'**
  String get articleHeaderTitle;

  /// No description provided for @articleHeaderBody.
  ///
  /// In ar, this message translates to:
  /// **'تُكتب مقالتك من إجاباتك العامّة على الرسائل المجهولة. كلما أجبت أكثر بصدق، كلما عرفك الذكاء أكثر — وكتب عنك أصدق.'**
  String get articleHeaderBody;

  /// No description provided for @articleNextTitle.
  ///
  /// In ar, this message translates to:
  /// **'المقالة التالية'**
  String get articleNextTitle;

  /// No description provided for @articleDaysRemaining.
  ///
  /// In ar, this message translates to:
  /// **'باقي {days} يوم على إنشاء مقالتك التالية.'**
  String articleDaysRemaining(Object days);

  /// No description provided for @articleCooldownNote.
  ///
  /// In ar, this message translates to:
  /// **'كل {days} يوم تستطيع إنشاء نسخة جديدة. النسخة الجديدة ستُبنى من إجاباتك الأحدث.'**
  String articleCooldownNote(Object days);

  /// No description provided for @articleProgress.
  ///
  /// In ar, this message translates to:
  /// **'تقدّمك'**
  String get articleProgress;

  /// No description provided for @articleNeedMore.
  ///
  /// In ar, this message translates to:
  /// **'تحتاج {count} إجابة عامّة إضافية على رسائل مجهولة لتفتح مقالتك. هذه الإجابات هي ما يجعل المقالة تشبهك حقاً.'**
  String articleNeedMore(Object count);

  /// No description provided for @articleGenerating.
  ///
  /// In ar, this message translates to:
  /// **'يجري الإنشاء…'**
  String get articleGenerating;

  /// No description provided for @articleRegenerateCta.
  ///
  /// In ar, this message translates to:
  /// **'أنشئ نسخة جديدة من مقالتي'**
  String get articleRegenerateCta;

  /// No description provided for @articleGenerateCta.
  ///
  /// In ar, this message translates to:
  /// **'اكتب مقالتي الآن ✨'**
  String get articleGenerateCta;

  /// No description provided for @articleSaved.
  ///
  /// In ar, this message translates to:
  /// **'تم الحفظ'**
  String get articleSaved;

  /// No description provided for @articleSaveFailed.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر الحفظ'**
  String get articleSaveFailed;

  /// No description provided for @articlePublishTitle.
  ///
  /// In ar, this message translates to:
  /// **'نشر المقالة للعموم'**
  String get articlePublishTitle;

  /// No description provided for @articlePublishBody.
  ///
  /// In ar, this message translates to:
  /// **'بعد 24 ساعة من النشر تصبح المقالة متاحة لأي شخص على رابط عام في المدوّنة. تستطيع حذفها متى شئت.'**
  String get articlePublishBody;

  /// No description provided for @articlePublishConfirm.
  ///
  /// In ar, this message translates to:
  /// **'انشر'**
  String get articlePublishConfirm;

  /// No description provided for @articlePublishScheduled.
  ///
  /// In ar, this message translates to:
  /// **'سَتظهر بعد 24 ساعة 🌙'**
  String get articlePublishScheduled;

  /// No description provided for @articlePublishFailed.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر النشر'**
  String get articlePublishFailed;

  /// No description provided for @articleDeleteTitle.
  ///
  /// In ar, this message translates to:
  /// **'حذف المقالة'**
  String get articleDeleteTitle;

  /// No description provided for @articleDeleteBody.
  ///
  /// In ar, this message translates to:
  /// **'سيتم حذف المقالة الحالية. ستظل النسخ السابقة محفوظة في الأرشيف.'**
  String get articleDeleteBody;

  /// No description provided for @articleDeleted.
  ///
  /// In ar, this message translates to:
  /// **'تم الحذف'**
  String get articleDeleted;

  /// No description provided for @articleDeleteFailed.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر الحذف'**
  String get articleDeleteFailed;

  /// No description provided for @articleStatusPublished.
  ///
  /// In ar, this message translates to:
  /// **'منشورة'**
  String get articleStatusPublished;

  /// No description provided for @articleStatusPrivate.
  ///
  /// In ar, this message translates to:
  /// **'خاصة'**
  String get articleStatusPrivate;

  /// No description provided for @articlePublishAction.
  ///
  /// In ar, this message translates to:
  /// **'نشرها'**
  String get articlePublishAction;

  /// No description provided for @articleEdit.
  ///
  /// In ar, this message translates to:
  /// **'تعديل'**
  String get articleEdit;

  /// No description provided for @articleDeleteHistoryTitle.
  ///
  /// In ar, this message translates to:
  /// **'حذف من الأرشيف'**
  String get articleDeleteHistoryTitle;

  /// No description provided for @articleDeleteHistoryBody.
  ///
  /// In ar, this message translates to:
  /// **'سيُحذف هذا الإصدار نهائياً من أرشيفك.'**
  String get articleDeleteHistoryBody;

  /// No description provided for @composeImageTooLarge.
  ///
  /// In ar, this message translates to:
  /// **'حجم الصورة أكبر من ١٥ ميجا'**
  String get composeImageTooLarge;

  /// No description provided for @composeCropImage.
  ///
  /// In ar, this message translates to:
  /// **'اقتصاص الصورة'**
  String get composeCropImage;

  /// No description provided for @composeUploadFailed.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر رفع الصورة'**
  String get composeUploadFailed;

  /// No description provided for @composePublishedToast.
  ///
  /// In ar, this message translates to:
  /// **'نُشِر بصدق ✨'**
  String get composePublishedToast;

  /// No description provided for @composePublishFailed.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر النشر'**
  String get composePublishFailed;

  /// No description provided for @composeDiscardTitle.
  ///
  /// In ar, this message translates to:
  /// **'تجاهل المسودة؟'**
  String get composeDiscardTitle;

  /// No description provided for @composeDiscardBody.
  ///
  /// In ar, this message translates to:
  /// **'ستفقد ما كتبته. هل تريد المتابعة؟'**
  String get composeDiscardBody;

  /// No description provided for @composeKeep.
  ///
  /// In ar, this message translates to:
  /// **'احتفاظ'**
  String get composeKeep;

  /// No description provided for @composeDiscard.
  ///
  /// In ar, this message translates to:
  /// **'تجاهل'**
  String get composeDiscard;

  /// No description provided for @composeClose.
  ///
  /// In ar, this message translates to:
  /// **'إغلاق'**
  String get composeClose;

  /// No description provided for @composeNewPost.
  ///
  /// In ar, this message translates to:
  /// **'منشور جديد'**
  String get composeNewPost;

  /// No description provided for @composeWriteFromHeart.
  ///
  /// In ar, this message translates to:
  /// **'اكتب من قلبك'**
  String get composeWriteFromHeart;

  /// No description provided for @composeLivesTitle.
  ///
  /// In ar, this message translates to:
  /// **'منشورك يعيش ٢٤ ساعة فقط'**
  String get composeLivesTitle;

  /// No description provided for @composeLivesBody.
  ///
  /// In ar, this message translates to:
  /// **'لو نال تفاعلات صادقة قبل انتهائها → يتبلور ✦ ويبقى للأبد. بدونها يختفي بهدوء. اطرح ما يستحق النقاش.'**
  String get composeLivesBody;

  /// No description provided for @composeLayer1Title.
  ///
  /// In ar, this message translates to:
  /// **'الطبقة ١ — الجوهر'**
  String get composeLayer1Title;

  /// No description provided for @composeLayer1Subtitle.
  ///
  /// In ar, this message translates to:
  /// **'الفكرة الأساسية في سطور قليلة'**
  String get composeLayer1Subtitle;

  /// No description provided for @composeLayer1Hint.
  ///
  /// In ar, this message translates to:
  /// **'ما الذي يدور في خاطرك؟'**
  String get composeLayer1Hint;

  /// No description provided for @composeLayer2Title.
  ///
  /// In ar, this message translates to:
  /// **'الطبقة ٢ — الصور'**
  String get composeLayer2Title;

  /// No description provided for @composeLayer2Subtitle.
  ///
  /// In ar, this message translates to:
  /// **'حتى ٤ صور (مربعة)'**
  String get composeLayer2Subtitle;

  /// No description provided for @composeUploading.
  ///
  /// In ar, this message translates to:
  /// **'جارٍ الرفع…'**
  String get composeUploading;

  /// No description provided for @composeAddImage.
  ///
  /// In ar, this message translates to:
  /// **'إضافة صورة'**
  String get composeAddImage;

  /// No description provided for @composeHideLayer3.
  ///
  /// In ar, this message translates to:
  /// **'إخفاء الطبقة ٣'**
  String get composeHideLayer3;

  /// No description provided for @composeAddLayer3.
  ///
  /// In ar, this message translates to:
  /// **'إضافة طبقة ٣ — تأمّل'**
  String get composeAddLayer3;

  /// No description provided for @composeLayer3Title.
  ///
  /// In ar, this message translates to:
  /// **'الطبقة ٣ — التأمل'**
  String get composeLayer3Title;

  /// No description provided for @composeLayer3Subtitle.
  ///
  /// In ar, this message translates to:
  /// **'نص طويل (حتى ٤٠٠٠ حرف)'**
  String get composeLayer3Subtitle;

  /// No description provided for @composeLayer3Hint.
  ///
  /// In ar, this message translates to:
  /// **'فكّر معنا… (اختياري)'**
  String get composeLayer3Hint;

  /// No description provided for @composeMomentDesc.
  ///
  /// In ar, this message translates to:
  /// **'سطر خاطف من يومك — شعور سريع، خاطرة، حدث الآن. الأقصر، الأصدق.'**
  String get composeMomentDesc;

  /// No description provided for @composeFaceDesc.
  ///
  /// In ar, this message translates to:
  /// **'صورة تحكي بصمتك مع تعليق قصير. للحظات البصرية التي تستحق الحفظ.'**
  String get composeFaceDesc;

  /// No description provided for @composeMindDesc.
  ///
  /// In ar, this message translates to:
  /// **'تأمّل أعمق تكتبه بهدوء. مكان للأفكار التي تحتاج وقتاً للقراءة.'**
  String get composeMindDesc;

  /// No description provided for @gameAiQLight.
  ///
  /// In ar, this message translates to:
  /// **'ما أكثر شيء يضحكك حالياً؟'**
  String get gameAiQLight;

  /// No description provided for @gameAiQFunny.
  ///
  /// In ar, this message translates to:
  /// **'أحرج موقف صار لك أمام الناس؟'**
  String get gameAiQFunny;

  /// No description provided for @gameAiQBold.
  ///
  /// In ar, this message translates to:
  /// **'ما السر الذي لم تخبر به أحداً؟'**
  String get gameAiQBold;

  /// No description provided for @helpTabFeatures.
  ///
  /// In ar, this message translates to:
  /// **'الميزات'**
  String get helpTabFeatures;

  /// No description provided for @helpTabFaq.
  ///
  /// In ar, this message translates to:
  /// **'أسئلة شائعة'**
  String get helpTabFaq;

  /// No description provided for @helpLegalLastUpdated.
  ///
  /// In ar, this message translates to:
  /// **'آخر تحديث: نوفمبر 2025'**
  String get helpLegalLastUpdated;

  /// No description provided for @helpLegalReadFull.
  ///
  /// In ar, this message translates to:
  /// **'قراءة النسخة الكاملة على الموقع'**
  String get helpLegalReadFull;

  /// No description provided for @helpLegalTermsSummary.
  ///
  /// In ar, this message translates to:
  /// **'بانضمامك إلى صارحني توافق على الالتزام بهذه الشروط:\n\n• العمر: التطبيق للبالغين (١٨ سنة فأكثر) فقط. أي حساب يتبين أنه لقاصر سيُحذف.\n\n• المحتوى: تلتزم بنشر محتوى لا يخالف القانون أو يحرّض على الإيذاء، ولا يحتوي على ابتزاز أو إباحية أو خطاب كراهية.\n\n• الرسائل المجهولة: تتفهم أن منصتنا تتيح إرسال رسائل مجهولة، وأنك مسؤول عن قراراتك في قبولها أو الإبلاغ عنها.\n\n• الحساب: مسؤوليتك حماية بريدك وكلمة مرورك. صارحني لن يطلب منك كلمة المرور أبداً.\n\n• التوقف عن الخدمة: نحتفظ بحق إيقاف أي حساب يخالف هذه الشروط دون إشعار مسبق.\n\n• القانون المعمول به: قوانين المملكة العربية السعودية تحكم استخدامك للتطبيق.\n\nلقراءة النسخة الكاملة والمحدّثة، افتح الرابط أدناه.'**
  String get helpLegalTermsSummary;

  /// No description provided for @helpLegalPrivacySummary.
  ///
  /// In ar, this message translates to:
  /// **'في صارحني، خصوصيتك جوهر تجربتنا:\n\n• ما نجمعه: البريد، اسم المستخدم، الصور والنصوص اللي تنشرها، عنوان IP عند الإرسال (لمكافحة الإساءة فقط).\n\n• ما لا نجمعه: لا نجمع جهات الاتصال، لا الموقع الدقيق، لا تاريخ التصفح خارج التطبيق.\n\n• الرسائل المجهولة: لا تظهر هوية المرسل لك أو لأي مستخدم آخر. نحتفظ بـ IP hash داخلياً لمدة ٣٠ يوماً لأغراض الإبلاغ القانوني فقط.\n\n• الإشعارات: لا نرسل إشعارات تسويقية. كل الإشعارات مرتبطة بنشاط داخل حسابك.\n\n• مشاركة البيانات: لا نبيع أي بيانات لأي طرف ثالث. نشارك فقط:\n  - عند طلب قضائي رسمي.\n  - مع مزودي البنية التحتية (السيرفر، التخزين السحابي) لتشغيل الخدمة.\n\n• حقوقك: تستطيع طلب نسخة من بياناتك أو حذف حسابك نهائياً من شاشة الإعدادات.\n\n• الأطفال: التطبيق ممنوع لمن دون ١٨ سنة. لو علمنا بحساب قاصر، نحذفه فوراً.\n\nللنسخة القانونية المفصّلة، افتح الرابط أدناه.'**
  String get helpLegalPrivacySummary;

  /// No description provided for @helpLegalContentSummary.
  ///
  /// In ar, this message translates to:
  /// **'كل المحتوى على صارحني يخضع لهذه السياسة:\n\n✓ مسموح: التعبير عن الرأي، الأسئلة الصادقة، الصور الشخصية المحتشمة، الفنّ، الأفكار التأملية.\n\n✗ ممنوع وفوراً يُحذف:\n• المحتوى الإباحي أو شبه الإباحي بأي شكل.\n• خطاب الكراهية ضد دين، عرق، أو جنس.\n• الابتزاز أو التهديد.\n• الترويج للعنف أو الإرهاب أو المخدرات.\n• كل ما يكشف هوية قاصر أو يستهدف القاصرين.\n• الإعلانات والروابط التسويقية المتطفلة.\n• انتحال شخصية الآخرين.\n\nنستخدم خوارزميات تعلّم آلي + مراجعة بشرية لرصد المخالفات. الإبلاغ متاح لكل المستخدمين من زر \"إبلاغ\" على أي منشور أو رسالة.'**
  String get helpLegalContentSummary;

  /// No description provided for @notifTitle.
  ///
  /// In ar, this message translates to:
  /// **'الإشعارات'**
  String get notifTitle;

  /// No description provided for @notifAllMarkedRead.
  ///
  /// In ar, this message translates to:
  /// **'تم وضع علامة كمقروء ({n})'**
  String notifAllMarkedRead(Object n);

  /// No description provided for @notifMarkReadFailed.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر التحديث'**
  String get notifMarkReadFailed;

  /// No description provided for @notifMarkAllRead.
  ///
  /// In ar, this message translates to:
  /// **'الكل مقروء'**
  String get notifMarkAllRead;

  /// No description provided for @notifEmptyTitle.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد إشعارات'**
  String get notifEmptyTitle;

  /// No description provided for @notifEmptySubtitle.
  ///
  /// In ar, this message translates to:
  /// **'سيظهر هنا تنبيهك عن كل جديد'**
  String get notifEmptySubtitle;

  /// No description provided for @notifLikedYourPost.
  ///
  /// In ar, this message translates to:
  /// **'أعجبهم منشورك'**
  String get notifLikedYourPost;

  /// No description provided for @notifCommentedOnYourPost.
  ///
  /// In ar, this message translates to:
  /// **'علّق على منشورك'**
  String get notifCommentedOnYourPost;

  /// No description provided for @notifStartedFollowingYou.
  ///
  /// In ar, this message translates to:
  /// **'بدأ متابعتك'**
  String get notifStartedFollowingYou;

  /// No description provided for @notifAnonymousQuestion.
  ///
  /// In ar, this message translates to:
  /// **'وصلك سؤال مجهول'**
  String get notifAnonymousQuestion;

  /// No description provided for @notifPostCrystallized.
  ///
  /// In ar, this message translates to:
  /// **'منشورك تبلور ✦'**
  String get notifPostCrystallized;

  /// No description provided for @searchHint.
  ///
  /// In ar, this message translates to:
  /// **'ابحث عن مستخدم أو تصفح المقترحين'**
  String get searchHint;

  /// No description provided for @searchEmptyBrowse.
  ///
  /// In ar, this message translates to:
  /// **'لا يوجد مستخدمون لعرضهم بعد'**
  String get searchEmptyBrowse;

  /// No description provided for @searchNoResults.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد نتائج تطابق \"{query}\"'**
  String searchNoResults(Object query);

  /// No description provided for @searchSuggestedForYou.
  ///
  /// In ar, this message translates to:
  /// **'مقترحون لك'**
  String get searchSuggestedForYou;

  /// No description provided for @settingsTierPro.
  ///
  /// In ar, this message translates to:
  /// **'برو'**
  String get settingsTierPro;

  /// No description provided for @settingsTierCreator.
  ///
  /// In ar, this message translates to:
  /// **'المبدع'**
  String get settingsTierCreator;

  /// No description provided for @settingsTierEternal.
  ///
  /// In ar, this message translates to:
  /// **'الخالدة'**
  String get settingsTierEternal;

  /// No description provided for @settingsTierFree.
  ///
  /// In ar, this message translates to:
  /// **'مجانية'**
  String get settingsTierFree;

  /// No description provided for @settingsPackagePrefix.
  ///
  /// In ar, this message translates to:
  /// **'باقة'**
  String get settingsPackagePrefix;

  /// No description provided for @settingsAttentionPrefix.
  ///
  /// In ar, this message translates to:
  /// **'الانتباه:'**
  String get settingsAttentionPrefix;

  /// No description provided for @settingsManageSubscription.
  ///
  /// In ar, this message translates to:
  /// **'إدارة الاشتراك'**
  String get settingsManageSubscription;

  /// No description provided for @settingsPlansTitle.
  ///
  /// In ar, this message translates to:
  /// **'الباقات'**
  String get settingsPlansTitle;

  /// No description provided for @settingsPlansSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'باقات سرحني تعطيك ميزانية انتباه أكبر، وحضوراً أعلى.'**
  String get settingsPlansSubtitle;

  /// No description provided for @settingsUpgraded.
  ///
  /// In ar, this message translates to:
  /// **'تم الترقية ✨'**
  String get settingsUpgraded;

  /// No description provided for @settingsUpgradeFailed.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر الترقية'**
  String get settingsUpgradeFailed;

  /// No description provided for @settingsSubscriptionCancelled.
  ///
  /// In ar, this message translates to:
  /// **'تم الإلغاء'**
  String get settingsSubscriptionCancelled;

  /// No description provided for @settingsCancelFailed.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر الإلغاء'**
  String get settingsCancelFailed;

  /// No description provided for @settingsDailyAttentionPrefix.
  ///
  /// In ar, this message translates to:
  /// **'الانتباه اليومي:'**
  String get settingsDailyAttentionPrefix;

  /// No description provided for @settingsCurrentPlan.
  ///
  /// In ar, this message translates to:
  /// **'باقتك الحالية'**
  String get settingsCurrentPlan;

  /// No description provided for @settingsCancelSubscription.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء الاشتراك'**
  String get settingsCancelSubscription;

  /// No description provided for @settingsUpgrade.
  ///
  /// In ar, this message translates to:
  /// **'ترقية'**
  String get settingsUpgrade;

  /// No description provided for @settingsBlockedEmptyTitle.
  ///
  /// In ar, this message translates to:
  /// **'لا يوجد محظورون'**
  String get settingsBlockedEmptyTitle;

  /// No description provided for @settingsBlockedEmptySubtitle.
  ///
  /// In ar, this message translates to:
  /// **'لما تحظر حساب، يظهر هنا و تقدر تلغي الحظر في أي وقت.'**
  String get settingsBlockedEmptySubtitle;

  /// No description provided for @settingsUnblocked.
  ///
  /// In ar, this message translates to:
  /// **'تم إلغاء الحظر'**
  String get settingsUnblocked;

  /// No description provided for @settingsUnblockFailed.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر إلغاء الحظر'**
  String get settingsUnblockFailed;

  /// No description provided for @settingsUnblock.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء الحظر'**
  String get settingsUnblock;

  /// No description provided for @reportReasonPostAbusive.
  ///
  /// In ar, this message translates to:
  /// **'محتوى مسيء أو شتائم'**
  String get reportReasonPostAbusive;

  /// No description provided for @reportReasonPostHarassment.
  ///
  /// In ar, this message translates to:
  /// **'تحرّش أو تنمّر'**
  String get reportReasonPostHarassment;

  /// No description provided for @reportReasonPostSexual.
  ///
  /// In ar, this message translates to:
  /// **'محتوى جنسي'**
  String get reportReasonPostSexual;

  /// No description provided for @reportReasonPostRacism.
  ///
  /// In ar, this message translates to:
  /// **'عنصرية أو تحريض'**
  String get reportReasonPostRacism;

  /// No description provided for @reportReasonPostSpam.
  ///
  /// In ar, this message translates to:
  /// **'spam أو محتوى مكرّر'**
  String get reportReasonPostSpam;

  /// No description provided for @reportReasonPostPrivacy.
  ///
  /// In ar, this message translates to:
  /// **'انتهاك خصوصية'**
  String get reportReasonPostPrivacy;

  /// No description provided for @reportReasonPostMisinfo.
  ///
  /// In ar, this message translates to:
  /// **'معلومات مضلّلة'**
  String get reportReasonPostMisinfo;

  /// No description provided for @reportReasonOther.
  ///
  /// In ar, this message translates to:
  /// **'أخرى'**
  String get reportReasonOther;

  /// No description provided for @reportReasonUserAbusive.
  ///
  /// In ar, this message translates to:
  /// **'حساب مسيء أو متنمّر'**
  String get reportReasonUserAbusive;

  /// No description provided for @reportReasonUserImpersonation.
  ///
  /// In ar, this message translates to:
  /// **'انتحال شخصية'**
  String get reportReasonUserImpersonation;

  /// No description provided for @reportReasonUserScam.
  ///
  /// In ar, this message translates to:
  /// **'حساب احتيالي / spam'**
  String get reportReasonUserScam;

  /// No description provided for @reportReasonUserMinors.
  ///
  /// In ar, this message translates to:
  /// **'يستهدف قاصرين'**
  String get reportReasonUserMinors;

  /// No description provided for @reportReasonUserSpamMessages.
  ///
  /// In ar, this message translates to:
  /// **'يكرّر إرسال رسائل مزعجة'**
  String get reportReasonUserSpamMessages;

  /// No description provided for @reportReasonUserProfile.
  ///
  /// In ar, this message translates to:
  /// **'محتوى ملف شخصي مخالف'**
  String get reportReasonUserProfile;

  /// No description provided for @reportNeedClearReason.
  ///
  /// In ar, this message translates to:
  /// **'اكتب سبباً واضحاً للإبلاغ'**
  String get reportNeedClearReason;

  /// No description provided for @reportReceived.
  ///
  /// In ar, this message translates to:
  /// **'تم استلام البلاغ. شكراً لك 🌙'**
  String get reportReceived;

  /// No description provided for @reportSendFailed.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر إرسال البلاغ'**
  String get reportSendFailed;

  /// No description provided for @reportTitlePost.
  ///
  /// In ar, this message translates to:
  /// **'الإبلاغ عن منشور'**
  String get reportTitlePost;

  /// No description provided for @reportTitleUser.
  ///
  /// In ar, this message translates to:
  /// **'الإبلاغ عن مستخدم'**
  String get reportTitleUser;

  /// No description provided for @reportConfidentialNote.
  ///
  /// In ar, this message translates to:
  /// **'البلاغات سرّية. فريق الإشراف يراجعها خلال 24 ساعة.'**
  String get reportConfidentialNote;

  /// No description provided for @reportExplainBriefly.
  ///
  /// In ar, this message translates to:
  /// **'اشرح السبب باختصار'**
  String get reportExplainBriefly;

  /// No description provided for @reportExtraDetails.
  ///
  /// In ar, this message translates to:
  /// **'تفاصيل إضافية (اختياري)'**
  String get reportExtraDetails;

  /// No description provided for @reportSubmit.
  ///
  /// In ar, this message translates to:
  /// **'إرسال البلاغ'**
  String get reportSubmit;

  /// No description provided for @commonComingSoon.
  ///
  /// In ar, this message translates to:
  /// **'قريباً…'**
  String get commonComingSoon;

  /// No description provided for @carromChatLoadFailed.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر تحميل الرسائل'**
  String get carromChatLoadFailed;

  /// No description provided for @carromWalletBalance.
  ///
  /// In ar, this message translates to:
  /// **'رصيدك الحالي'**
  String get carromWalletBalance;

  /// No description provided for @carromWalletLoadFailed.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر تحميل الرصيد'**
  String get carromWalletLoadFailed;

  /// No description provided for @carromGotIt.
  ///
  /// In ar, this message translates to:
  /// **'حسناً'**
  String get carromGotIt;

  /// No description provided for @carromAimAnglePower.
  ///
  /// In ar, this message translates to:
  /// **'زاوية {angle}° · قوة {power}%'**
  String carromAimAnglePower(Object angle, Object power);

  /// No description provided for @carromAimDragStriker.
  ///
  /// In ar, this message translates to:
  /// **'اسحب الستراكر يساراً أو يميناً'**
  String get carromAimDragStriker;

  /// No description provided for @carromMmSearchFailed.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر البحث عن منافس'**
  String get carromMmSearchFailed;

  /// No description provided for @carromMmWaitAverage.
  ///
  /// In ar, this message translates to:
  /// **'متوسط الانتظار أقل من 30 ثانية'**
  String get carromMmWaitAverage;

  /// No description provided for @carromMmWaitLongTitle.
  ///
  /// In ar, this message translates to:
  /// **'الانتظار طال؟'**
  String get carromMmWaitLongTitle;

  /// No description provided for @carromMmVsComputerSoon.
  ///
  /// In ar, this message translates to:
  /// **'مباراة ضد الكمبيوتر — قريباً'**
  String get carromMmVsComputerSoon;

  /// No description provided for @carromInviteCreateFailed.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر إنشاء الدعوة'**
  String get carromInviteCreateFailed;

  /// No description provided for @carromInvitePasteFirst.
  ///
  /// In ar, this message translates to:
  /// **'الصق رمز الدعوة أولاً'**
  String get carromInvitePasteFirst;

  /// No description provided for @carromInviteJoinFailed.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر الانضمام للدعوة'**
  String get carromInviteJoinFailed;

  /// No description provided for @carromInviteYourCode.
  ///
  /// In ar, this message translates to:
  /// **'رمز دعوتك'**
  String get carromInviteYourCode;

  /// No description provided for @carromInviteCodeHint.
  ///
  /// In ar, this message translates to:
  /// **'صلاحية الرمز 5 دقائق. شارك الرمز مع صديقك ليدخل المباراة.'**
  String get carromInviteCodeHint;

  /// No description provided for @carromInviteCopied.
  ///
  /// In ar, this message translates to:
  /// **'نُسخ الرمز'**
  String get carromInviteCopied;

  /// No description provided for @carromInviteEnterRoom.
  ///
  /// In ar, this message translates to:
  /// **'ادخل الغرفة'**
  String get carromInviteEnterRoom;

  /// No description provided for @carromWalletLoading.
  ///
  /// In ar, this message translates to:
  /// **'جارٍ تحميل المحفظة...'**
  String get carromWalletLoading;

  /// No description provided for @carromRulesTitle.
  ///
  /// In ar, this message translates to:
  /// **'القواعد السريعة'**
  String get carromRulesTitle;

  /// No description provided for @carromRule1.
  ///
  /// In ar, this message translates to:
  /// **'• اسحب من الستراكر للداخل لتصويب — كل ما طال السحب، زادت القوة'**
  String get carromRule1;

  /// No description provided for @carromRule2.
  ///
  /// In ar, this message translates to:
  /// **'• قطع بيضاء = 1 نقطة، سوداء = 2، الملكة = 3 (لكن لازم تغطّيها)'**
  String get carromRule2;

  /// No description provided for @carromRule3.
  ///
  /// In ar, this message translates to:
  /// **'• كل دور تأخذه إذا أدخلت قطعة من لونك، وتفقد الدور لو فاولت'**
  String get carromRule3;

  /// No description provided for @carromRule4.
  ///
  /// In ar, this message translates to:
  /// **'• الفائز يكشف لخصمه (اختياري) ويأخذ كل النقاط'**
  String get carromRule4;

  /// No description provided for @carromConcedeTitle.
  ///
  /// In ar, this message translates to:
  /// **'هل تستسلم؟'**
  String get carromConcedeTitle;

  /// No description provided for @carromConcedeBody.
  ///
  /// In ar, this message translates to:
  /// **'إذا انسحبت الآن سيفوز خصمك بـ {pot} نقطة. لا يمكن التراجع.'**
  String carromConcedeBody(Object pot);

  /// No description provided for @carromConcedeContinue.
  ///
  /// In ar, this message translates to:
  /// **'متابعة المباراة'**
  String get carromConcedeContinue;

  /// No description provided for @carromGameTitle.
  ///
  /// In ar, this message translates to:
  /// **'كيرم'**
  String get carromGameTitle;

  /// No description provided for @carromReconnectAttempt.
  ///
  /// In ar, this message translates to:
  /// **'إعادة الاتصال... (محاولة #{attempt})'**
  String carromReconnectAttempt(Object attempt);

  /// No description provided for @carromOpponentDisconnected.
  ///
  /// In ar, this message translates to:
  /// **'خصمك انقطع — في انتظاره '**
  String get carromOpponentDisconnected;

  /// No description provided for @carromRematchStartFailed.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر بدء الإعادة الآن'**
  String get carromRematchStartFailed;

  /// No description provided for @carromActionFailed.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر تنفيذ الإجراء حالياً'**
  String get carromActionFailed;

  /// No description provided for @carromRevealSent.
  ///
  /// In ar, this message translates to:
  /// **'تم — لو وافق خصمك، تتبادلون الهوية'**
  String get carromRevealSent;

  /// No description provided for @carromStayedAnonymous.
  ///
  /// In ar, this message translates to:
  /// **'بقيت مجهولاً'**
  String get carromStayedAnonymous;

  /// No description provided for @carromRequestFailed.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر إرسال الطلب'**
  String get carromRequestFailed;

  /// No description provided for @carromSarhnyTitle.
  ///
  /// In ar, this message translates to:
  /// **'رسالة صراحة لخصمك'**
  String get carromSarhnyTitle;

  /// No description provided for @carromSarhnySubtitle.
  ///
  /// In ar, this message translates to:
  /// **'ستصل لـ inbox الخصم مع علامة \"لعب معك كيرم\"'**
  String get carromSarhnySubtitle;

  /// No description provided for @carromSarhnyHint.
  ///
  /// In ar, this message translates to:
  /// **'اكتب رسالتك...'**
  String get carromSarhnyHint;

  /// No description provided for @carromMessageTooShort.
  ///
  /// In ar, this message translates to:
  /// **'الرسالة قصيرة جداً'**
  String get carromMessageTooShort;

  /// No description provided for @carromSendFailed.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر الإرسال'**
  String get carromSendFailed;

  /// No description provided for @carromMessageDelivered.
  ///
  /// In ar, this message translates to:
  /// **'وصلت رسالتك للخصم'**
  String get carromMessageDelivered;

  /// No description provided for @carromAdReward.
  ///
  /// In ar, this message translates to:
  /// **'+{credited} نقطة — رصيدك: {balance}'**
  String carromAdReward(Object credited, Object balance);

  /// No description provided for @carromAdDailyCap.
  ///
  /// In ar, this message translates to:
  /// **'وصلت الحد اليومي (10 إعلانات)'**
  String get carromAdDailyCap;

  /// No description provided for @carromAdUnavailable.
  ///
  /// In ar, this message translates to:
  /// **'الإعلان غير متاح حالياً — حاول لاحقاً'**
  String get carromAdUnavailable;

  /// No description provided for @carromAdVerifyFailed.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر التحقق من الإعلان'**
  String get carromAdVerifyFailed;

  /// No description provided for @carromAdUnsupported.
  ///
  /// In ar, this message translates to:
  /// **'الإعلانات غير مدعومة على هذه المنصة'**
  String get carromAdUnsupported;

  /// No description provided for @carromAdRewardFailed.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر إضافة المكافأة'**
  String get carromAdRewardFailed;

  /// No description provided for @carromRevealTitle.
  ///
  /// In ar, this message translates to:
  /// **'اكشف هويتك للخصم'**
  String get carromRevealTitle;

  /// No description provided for @carromRevealSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'تتبادلون الكشف — مجاناً'**
  String get carromRevealSubtitle;

  /// No description provided for @carromHideTitle.
  ///
  /// In ar, this message translates to:
  /// **'أخفِ هويتي'**
  String get carromHideTitle;

  /// No description provided for @carromHideSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'تبقى مجهولاً — يخصم 10 نقاط'**
  String get carromHideSubtitle;

  /// No description provided for @carromSendSarhnyTitle.
  ///
  /// In ar, this message translates to:
  /// **'أرسل رسالة صراحة'**
  String get carromSendSarhnyTitle;

  /// No description provided for @carromSendSarhnySubtitle.
  ///
  /// In ar, this message translates to:
  /// **'إلى inbox الخصم — مع سياق المباراة'**
  String get carromSendSarhnySubtitle;

  /// No description provided for @carromWatchAdTitle.
  ///
  /// In ar, this message translates to:
  /// **'شاهد إعلان لـ +1 نقطة'**
  String get carromWatchAdTitle;

  /// No description provided for @carromWatchAdSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'حدّ أقصى 10 إعلانات يومياً'**
  String get carromWatchAdSubtitle;

  /// No description provided for @carromSendSarhnyShort.
  ///
  /// In ar, this message translates to:
  /// **'أرسل صراحة'**
  String get carromSendSarhnyShort;

  /// No description provided for @carromSendSarhnyShortSub.
  ///
  /// In ar, this message translates to:
  /// **'أرسل رسالة لخصمك — بدون كشف هويتك'**
  String get carromSendSarhnyShortSub;

  /// No description provided for @carromOpponentConceded.
  ///
  /// In ar, this message translates to:
  /// **'خصمك انسحب'**
  String get carromOpponentConceded;

  /// No description provided for @carromOpponentConcededSub.
  ///
  /// In ar, this message translates to:
  /// **'اللقب لك. مباراة جديدة؟'**
  String get carromOpponentConcededSub;

  /// No description provided for @carromYouConceded.
  ///
  /// In ar, this message translates to:
  /// **'انسحبت من هذه المباراة'**
  String get carromYouConceded;

  /// No description provided for @carromYouConcededSub.
  ///
  /// In ar, this message translates to:
  /// **'كل مباراة درس. حاول مرة أخرى متى أردت.'**
  String get carromYouConcededSub;

  /// No description provided for @carromWonSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'أنت بطل هذه المباراة'**
  String get carromWonSubtitle;

  /// No description provided for @carromLostSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'كل مباراة فرصة جديدة'**
  String get carromLostSubtitle;

  /// No description provided for @carromPoints.
  ///
  /// In ar, this message translates to:
  /// **'نقطة'**
  String get carromPoints;

  /// No description provided for @carromBackToLobby.
  ///
  /// In ar, this message translates to:
  /// **'العودة للوبي'**
  String get carromBackToLobby;

  /// No description provided for @carromSearchOther.
  ///
  /// In ar, this message translates to:
  /// **'البحث عن منافس آخر'**
  String get carromSearchOther;

  /// No description provided for @carromRematchWaiting.
  ///
  /// In ar, this message translates to:
  /// **'بانتظار قبول الخصم… ({seconds} ث)'**
  String carromRematchWaiting(Object seconds);

  /// No description provided for @carromRematchWaitingHint.
  ///
  /// In ar, this message translates to:
  /// **'لو ضغط الخصم \"إعادة\"، تبدأ المباراة فوراً'**
  String get carromRematchWaitingHint;

  /// No description provided for @carromRematchDeclined.
  ///
  /// In ar, this message translates to:
  /// **'الخصم لم يقبل الإعادة'**
  String get carromRematchDeclined;

  /// No description provided for @carromRematchTimeout.
  ///
  /// In ar, this message translates to:
  /// **'انتهى الوقت — الخصم غير متاح'**
  String get carromRematchTimeout;

  /// No description provided for @carromRematchSameOpponent.
  ///
  /// In ar, this message translates to:
  /// **'أو أعد مع نفس الخصم'**
  String get carromRematchSameOpponent;

  /// No description provided for @carromRematchSameOpponentAction.
  ///
  /// In ar, this message translates to:
  /// **'إعادة مع نفس الخصم'**
  String get carromRematchSameOpponentAction;

  /// No description provided for @carromRematchAction.
  ///
  /// In ar, this message translates to:
  /// **'إعادة'**
  String get carromRematchAction;

  /// No description provided for @carromWhatHappenedLabel.
  ///
  /// In ar, this message translates to:
  /// **'ماذا حدث في هذه المباراة'**
  String get carromWhatHappenedLabel;

  /// No description provided for @carromMatchReviewSoon.
  ///
  /// In ar, this message translates to:
  /// **'مراجعة المباراة (قريباً)'**
  String get carromMatchReviewSoon;

  /// No description provided for @carromWhatHappened.
  ///
  /// In ar, this message translates to:
  /// **'ماذا حدث؟'**
  String get carromWhatHappened;

  /// No description provided for @carromSoon.
  ///
  /// In ar, this message translates to:
  /// **'قريباً'**
  String get carromSoon;

  /// No description provided for @carromReviewMovesSoon.
  ///
  /// In ar, this message translates to:
  /// **'راجع آخر حركاتك (قريباً)'**
  String get carromReviewMovesSoon;

  /// No description provided for @carromMmRaceHint.
  ///
  /// In ar, this message translates to:
  /// **'سيبدأ من يصل أولاً باللعب'**
  String get carromMmRaceHint;

  /// No description provided for @carromCosmeticsTitle2.
  ///
  /// In ar, this message translates to:
  /// **'أشكال كيرم'**
  String get carromCosmeticsTitle2;

  /// No description provided for @carromCosmeticsBoard.
  ///
  /// In ar, this message translates to:
  /// **'الطاولة'**
  String get carromCosmeticsBoard;

  /// No description provided for @carromCosmeticsPieces.
  ///
  /// In ar, this message translates to:
  /// **'الأحجار'**
  String get carromCosmeticsPieces;

  /// No description provided for @carromCosmeticsSound.
  ///
  /// In ar, this message translates to:
  /// **'الصوت'**
  String get carromCosmeticsSound;

  /// No description provided for @carromCosmeticsMute.
  ///
  /// In ar, this message translates to:
  /// **'كتم أصوات اللعبة'**
  String get carromCosmeticsMute;

  /// No description provided for @carromBoardWalnut.
  ///
  /// In ar, this message translates to:
  /// **'خشب فاخر'**
  String get carromBoardWalnut;

  /// No description provided for @carromBoardSapphire.
  ///
  /// In ar, this message translates to:
  /// **'أزرق ملكي'**
  String get carromBoardSapphire;

  /// No description provided for @carromBoardEmerald.
  ///
  /// In ar, this message translates to:
  /// **'أخضر زمردي'**
  String get carromBoardEmerald;

  /// No description provided for @carromCoinClassic.
  ///
  /// In ar, this message translates to:
  /// **'كلاسيكي'**
  String get carromCoinClassic;

  /// No description provided for @carromCoinRoyal.
  ///
  /// In ar, this message translates to:
  /// **'ملكي ذهبي'**
  String get carromCoinRoyal;

  /// No description provided for @carromCoinVivid.
  ///
  /// In ar, this message translates to:
  /// **'زاهي'**
  String get carromCoinVivid;

  /// No description provided for @carromCoinCandy.
  ///
  /// In ar, this message translates to:
  /// **'حلوى'**
  String get carromCoinCandy;

  /// No description provided for @carromChatNiceGame.
  ///
  /// In ar, this message translates to:
  /// **'لعبة حلوة'**
  String get carromChatNiceGame;

  /// No description provided for @carromChatFireShot.
  ///
  /// In ar, this message translates to:
  /// **'ضربة نار'**
  String get carromChatFireShot;

  /// No description provided for @carromChatPreciseAim.
  ///
  /// In ar, this message translates to:
  /// **'تصويب دقيق'**
  String get carromChatPreciseAim;

  /// No description provided for @carromChatWatchLearn.
  ///
  /// In ar, this message translates to:
  /// **'شوف وتعلّم'**
  String get carromChatWatchLearn;

  /// No description provided for @carromChatMyLuck.
  ///
  /// In ar, this message translates to:
  /// **'يا حظّي'**
  String get carromChatMyLuck;

  /// No description provided for @carromChatBravo.
  ///
  /// In ar, this message translates to:
  /// **'برافو'**
  String get carromChatBravo;

  /// No description provided for @carromChatWow.
  ///
  /// In ar, this message translates to:
  /// **'واو!'**
  String get carromChatWow;

  /// No description provided for @carromChatGoodLuck.
  ///
  /// In ar, this message translates to:
  /// **'حظ موفّق'**
  String get carromChatGoodLuck;

  /// No description provided for @carromChatEasy.
  ///
  /// In ar, this message translates to:
  /// **'سهلة'**
  String get carromChatEasy;

  /// No description provided for @carromChatMadeItHard.
  ///
  /// In ar, this message translates to:
  /// **'صعّبتها'**
  String get carromChatMadeItHard;

  /// No description provided for @carromChatCovered.
  ///
  /// In ar, this message translates to:
  /// **'غطّاها!'**
  String get carromChatCovered;

  /// No description provided for @carromChatBeautifulGame.
  ///
  /// In ar, this message translates to:
  /// **'لعبة جميلة'**
  String get carromChatBeautifulGame;

  /// No description provided for @carromMatchWonMatch.
  ///
  /// In ar, this message translates to:
  /// **'فزت بالمباراة 🏆'**
  String get carromMatchWonMatch;

  /// No description provided for @carromMatchOppWon.
  ///
  /// In ar, this message translates to:
  /// **'فاز الخصم'**
  String get carromMatchOppWon;

  /// No description provided for @carromMatchOppAiming.
  ///
  /// In ar, this message translates to:
  /// **'الخصم يصوّب…'**
  String get carromMatchOppAiming;

  /// No description provided for @carromMatchPiecesMoving.
  ///
  /// In ar, this message translates to:
  /// **'القطع تتحرك…'**
  String get carromMatchPiecesMoving;

  /// No description provided for @carromMatchOppCoversQueen.
  ///
  /// In ar, this message translates to:
  /// **'الخصم يغطّي الملكة 👑'**
  String get carromMatchOppCoversQueen;

  /// No description provided for @carromMatchCoverQueen.
  ///
  /// In ar, this message translates to:
  /// **'غطِّ الملكة 👑 — أسقط قطعة من قطعك'**
  String get carromMatchCoverQueen;

  /// No description provided for @carromMatchYourTurnHint.
  ///
  /// In ar, this message translates to:
  /// **'دورك — اسحب المضرب للخلف للتصويب، ثم أفلت'**
  String get carromMatchYourTurnHint;

  /// No description provided for @carromMatchTitle.
  ///
  /// In ar, this message translates to:
  /// **'كيرم'**
  String get carromMatchTitle;

  /// No description provided for @carromOnlineTitle.
  ///
  /// In ar, this message translates to:
  /// **'كيرم أونلاين'**
  String get carromOnlineTitle;

  /// No description provided for @carromUnmute.
  ///
  /// In ar, this message translates to:
  /// **'تشغيل الصوت'**
  String get carromUnmute;

  /// No description provided for @carromMute.
  ///
  /// In ar, this message translates to:
  /// **'كتم الصوت'**
  String get carromMute;

  /// No description provided for @carromSkins.
  ///
  /// In ar, this message translates to:
  /// **'الأشكال'**
  String get carromSkins;

  /// No description provided for @carromYou.
  ///
  /// In ar, this message translates to:
  /// **'أنت'**
  String get carromYou;

  /// No description provided for @carromOpponent.
  ///
  /// In ar, this message translates to:
  /// **'الخصم'**
  String get carromOpponent;

  /// No description provided for @carromFoulStriker.
  ///
  /// In ar, this message translates to:
  /// **'خطأ: المضرب دخل الجيب'**
  String get carromFoulStriker;

  /// No description provided for @carromFoulNoHit.
  ///
  /// In ar, this message translates to:
  /// **'خطأ: لم تلمس أي قطعة'**
  String get carromFoulNoHit;

  /// No description provided for @carromFoulTimeout.
  ///
  /// In ar, this message translates to:
  /// **'انتهى وقتك — تمريرة للخصم'**
  String get carromFoulTimeout;

  /// No description provided for @carromFoulTimeoutOnline.
  ///
  /// In ar, this message translates to:
  /// **'انتهى وقت اللاعب — تمريرة'**
  String get carromFoulTimeoutOnline;

  /// No description provided for @carromFoul.
  ///
  /// In ar, this message translates to:
  /// **'خطأ'**
  String get carromFoul;

  /// No description provided for @carromQaWinAsk.
  ///
  /// In ar, this message translates to:
  /// **'فزت! اسأل خصمك سؤالاً'**
  String get carromQaWinAsk;

  /// No description provided for @carromQaLoseAnswer.
  ///
  /// In ar, this message translates to:
  /// **'فاز الخصم — أجب على سؤاله'**
  String get carromQaLoseAnswer;

  /// No description provided for @carromQaQuestionHint.
  ///
  /// In ar, this message translates to:
  /// **'اكتب سؤالك للخصم…'**
  String get carromQaQuestionHint;

  /// No description provided for @carromQaAnswerHint.
  ///
  /// In ar, this message translates to:
  /// **'اكتب إجابتك…'**
  String get carromQaAnswerHint;

  /// No description provided for @carromQaFetchingQuestion.
  ///
  /// In ar, this message translates to:
  /// **'يجلب السؤال…'**
  String get carromQaFetchingQuestion;

  /// No description provided for @carromQaPrivate.
  ///
  /// In ar, this message translates to:
  /// **'خاص — لا يُحفظ'**
  String get carromQaPrivate;

  /// No description provided for @carromQaWaitingAnswer.
  ///
  /// In ar, this message translates to:
  /// **'بانتظار إجابة الخصم…'**
  String get carromQaWaitingAnswer;

  /// No description provided for @carromQaWaitingQuestion.
  ///
  /// In ar, this message translates to:
  /// **'بانتظار سؤال الخصم…'**
  String get carromQaWaitingQuestion;

  /// No description provided for @carromQaAnswerSent.
  ///
  /// In ar, this message translates to:
  /// **'تم إرسال إجابتك ✓'**
  String get carromQaAnswerSent;

  /// No description provided for @carromBubbleOppAnswer.
  ///
  /// In ar, this message translates to:
  /// **'إجابة الخصم'**
  String get carromBubbleOppAnswer;

  /// No description provided for @carromBubbleOppQuestion.
  ///
  /// In ar, this message translates to:
  /// **'سؤال الخصم'**
  String get carromBubbleOppQuestion;

  /// No description provided for @carromSkip.
  ///
  /// In ar, this message translates to:
  /// **'تخطّي'**
  String get carromSkip;

  /// No description provided for @carromFinish.
  ///
  /// In ar, this message translates to:
  /// **'إنهاء'**
  String get carromFinish;

  /// No description provided for @carromSendQuestion.
  ///
  /// In ar, this message translates to:
  /// **'إرسال السؤال'**
  String get carromSendQuestion;

  /// No description provided for @carromSendAnswer.
  ///
  /// In ar, this message translates to:
  /// **'إرسال الإجابة'**
  String get carromSendAnswer;

  /// No description provided for @carromYouWon.
  ///
  /// In ar, this message translates to:
  /// **'فزت!'**
  String get carromYouWon;

  /// No description provided for @carromNewMatch.
  ///
  /// In ar, this message translates to:
  /// **'مباراة جديدة'**
  String get carromNewMatch;

  /// No description provided for @carromNewOpponent.
  ///
  /// In ar, this message translates to:
  /// **'خصم جديد'**
  String get carromNewOpponent;

  /// No description provided for @carromOppLeft.
  ///
  /// In ar, this message translates to:
  /// **'غادر الخصم'**
  String get carromOppLeft;

  /// No description provided for @carromConnected.
  ///
  /// In ar, this message translates to:
  /// **'متصل'**
  String get carromConnected;

  /// No description provided for @carromConnecting.
  ///
  /// In ar, this message translates to:
  /// **'يتصل…'**
  String get carromConnecting;

  /// No description provided for @carromAimMoveStriker.
  ///
  /// In ar, this message translates to:
  /// **'حرّك الستراكر يميناً ويساراً'**
  String get carromAimMoveStriker;

  /// No description provided for @carromAimDragToAim.
  ///
  /// In ar, this message translates to:
  /// **'اسحب الستراكر للتصويب'**
  String get carromAimDragToAim;

  /// No description provided for @carromMmAvgWait.
  ///
  /// In ar, this message translates to:
  /// **'متوسط الانتظار أقل من ٣٠ ثانية'**
  String get carromMmAvgWait;

  /// No description provided for @carromOnlineWon.
  ///
  /// In ar, this message translates to:
  /// **'فزت! 🏆'**
  String get carromOnlineWon;

  /// No description provided for @carromOnlineLost.
  ///
  /// In ar, this message translates to:
  /// **'لقد خسرت'**
  String get carromOnlineLost;

  /// No description provided for @carromScoreYou.
  ///
  /// In ar, this message translates to:
  /// **'أنت'**
  String get carromScoreYou;

  /// No description provided for @carromScoreOpp.
  ///
  /// In ar, this message translates to:
  /// **'خصم'**
  String get carromScoreOpp;

  /// No description provided for @carromOpponentLeft.
  ///
  /// In ar, this message translates to:
  /// **'خصمك غادر — تنتظر العودة'**
  String get carromOpponentLeft;

  /// No description provided for @carromConcedeAction.
  ///
  /// In ar, this message translates to:
  /// **'استسلم'**
  String get carromConcedeAction;

  /// No description provided for @carromMatchOver.
  ///
  /// In ar, this message translates to:
  /// **'انتهت المباراة'**
  String get carromMatchOver;

  /// No description provided for @carromTurnYouAim.
  ///
  /// In ar, this message translates to:
  /// **'دورك — صوّب'**
  String get carromTurnYouAim;

  /// No description provided for @carromTurnWaitOpp.
  ///
  /// In ar, this message translates to:
  /// **'انتظار خصمك…'**
  String get carromTurnWaitOpp;

  /// No description provided for @carromExitTitle.
  ///
  /// In ar, this message translates to:
  /// **'هل تخرج من المباراة؟'**
  String get carromExitTitle;

  /// No description provided for @carromExitBody.
  ///
  /// In ar, this message translates to:
  /// **'سيتم احتساب الجولة الحالية كخسارة.'**
  String get carromExitBody;

  /// No description provided for @carromExitAction.
  ///
  /// In ar, this message translates to:
  /// **'خروج'**
  String get carromExitAction;

  /// No description provided for @carromTitleShort.
  ///
  /// In ar, this message translates to:
  /// **'كيرم'**
  String get carromTitleShort;

  /// No description provided for @carromPiecesMoving.
  ///
  /// In ar, this message translates to:
  /// **'القطع تتحرك…'**
  String get carromPiecesMoving;

  /// No description provided for @carromStatusDragHint.
  ///
  /// In ar, this message translates to:
  /// **'اسحب من المضرب وحدد القوة والزاوية'**
  String get carromStatusDragHint;

  /// No description provided for @carromNewPractice.
  ///
  /// In ar, this message translates to:
  /// **'تدريب جديد'**
  String get carromNewPractice;

  /// No description provided for @carromFoulStrikerPocketed.
  ///
  /// In ar, this message translates to:
  /// **'خطأ: المضرب دخل في الجيب'**
  String get carromFoulStrikerPocketed;

  /// No description provided for @carromFoulNoPieceHit.
  ///
  /// In ar, this message translates to:
  /// **'خطأ: لم تلمس قطعة'**
  String get carromFoulNoPieceHit;

  /// No description provided for @carromFoulWrongColor.
  ///
  /// In ar, this message translates to:
  /// **'خطأ: لمست قطعة الخصم أولاً'**
  String get carromFoulWrongColor;

  /// No description provided for @carromFoulQueenUncovered.
  ///
  /// In ar, this message translates to:
  /// **'خطأ: التاج بدون تغطية'**
  String get carromFoulQueenUncovered;

  /// No description provided for @carromFoulGeneric.
  ///
  /// In ar, this message translates to:
  /// **'خطأ في الرمية'**
  String get carromFoulGeneric;

  /// No description provided for @carromChatToughOne.
  ///
  /// In ar, this message translates to:
  /// **'صعّبتها'**
  String get carromChatToughOne;

  /// No description provided for @carromChatNicePlay.
  ///
  /// In ar, this message translates to:
  /// **'لعبة جميلة'**
  String get carromChatNicePlay;

  /// No description provided for @carromConcedeProTitle.
  ///
  /// In ar, this message translates to:
  /// **'هل تنسحب من المباراة؟'**
  String get carromConcedeProTitle;

  /// No description provided for @carromConcedeProBody.
  ///
  /// In ar, this message translates to:
  /// **'ستُحتسب خسارة.'**
  String get carromConcedeProBody;

  /// No description provided for @carromWithdraw.
  ///
  /// In ar, this message translates to:
  /// **'انسحاب'**
  String get carromWithdraw;

  /// No description provided for @carromProTitle.
  ///
  /// In ar, this message translates to:
  /// **'كيرم برو'**
  String get carromProTitle;

  /// No description provided for @carromChat.
  ///
  /// In ar, this message translates to:
  /// **'دردشة'**
  String get carromChat;

  /// No description provided for @carromStatusWonMatch.
  ///
  /// In ar, this message translates to:
  /// **'فزت بالمباراة 🏆'**
  String get carromStatusWonMatch;

  /// No description provided for @carromStatusOppWon.
  ///
  /// In ar, this message translates to:
  /// **'فاز الخصم'**
  String get carromStatusOppWon;

  /// No description provided for @carromStatusOppAiming.
  ///
  /// In ar, this message translates to:
  /// **'الخصم يصوّب…'**
  String get carromStatusOppAiming;

  /// No description provided for @carromStatusOppCoverQueen.
  ///
  /// In ar, this message translates to:
  /// **'الخصم يغطّي الملكة 👑'**
  String get carromStatusOppCoverQueen;

  /// No description provided for @carromStatusCoverQueen.
  ///
  /// In ar, this message translates to:
  /// **'غطِّ الملكة 👑 — أسقط قطعة من قطعك'**
  String get carromStatusCoverQueen;

  /// No description provided for @carromStatusYourTurnDrag.
  ///
  /// In ar, this message translates to:
  /// **'دورك — اسحب المضرب، وجّه، ثم أفلت'**
  String get carromStatusYourTurnDrag;

  /// No description provided for @carromFoulStrikerPocketed2.
  ///
  /// In ar, this message translates to:
  /// **'خطأ: المضرب دخل الجيب'**
  String get carromFoulStrikerPocketed2;

  /// No description provided for @carromFoulNoPieceHit2.
  ///
  /// In ar, this message translates to:
  /// **'خطأ: لم تلمس أي قطعة'**
  String get carromFoulNoPieceHit2;

  /// No description provided for @ludoInviteCreateFailed.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر إنشاء الدعوة'**
  String get ludoInviteCreateFailed;

  /// No description provided for @ludoInvitePasteFirst.
  ///
  /// In ar, this message translates to:
  /// **'الصق رمز الدعوة أولاً'**
  String get ludoInvitePasteFirst;

  /// No description provided for @ludoInviteJoinFailed.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر الانضمام للدعوة'**
  String get ludoInviteJoinFailed;

  /// No description provided for @ludoInviteCodeTitle.
  ///
  /// In ar, this message translates to:
  /// **'رمز دعوتك'**
  String get ludoInviteCodeTitle;

  /// No description provided for @ludoInviteCodeHint.
  ///
  /// In ar, this message translates to:
  /// **'صلاحية الرمز 5 دقائق. شارك الرمز لينضموا للمباراة.'**
  String get ludoInviteCodeHint;

  /// No description provided for @ludoCodeCopied.
  ///
  /// In ar, this message translates to:
  /// **'نُسخ الرمز'**
  String get ludoCodeCopied;

  /// No description provided for @ludoCopy.
  ///
  /// In ar, this message translates to:
  /// **'نسخ'**
  String get ludoCopy;

  /// No description provided for @ludoEnterRoom.
  ///
  /// In ar, this message translates to:
  /// **'ادخل الغرفة'**
  String get ludoEnterRoom;

  /// No description provided for @ludoBadgeNew.
  ///
  /// In ar, this message translates to:
  /// **'جديد'**
  String get ludoBadgeNew;

  /// No description provided for @ludoBadge2to4.
  ///
  /// In ar, this message translates to:
  /// **'2-4 لاعبين'**
  String get ludoBadge2to4;

  /// No description provided for @ludoHeroTitle.
  ///
  /// In ar, this message translates to:
  /// **'لودو الذهبي'**
  String get ludoHeroTitle;

  /// No description provided for @ludoHeroSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'الزهر يقرر، والشجاعة تربح'**
  String get ludoHeroSubtitle;

  /// No description provided for @ludoChooseMode.
  ///
  /// In ar, this message translates to:
  /// **'اختر نمط اللعب'**
  String get ludoChooseMode;

  /// No description provided for @ludoMoment.
  ///
  /// In ar, this message translates to:
  /// **'لحظة…'**
  String get ludoMoment;

  /// No description provided for @ludoStartMatch.
  ///
  /// In ar, this message translates to:
  /// **'ابدأ مباراة'**
  String get ludoStartMatch;

  /// No description provided for @ludoPlayWithFriends.
  ///
  /// In ar, this message translates to:
  /// **'العب مع أصدقاء'**
  String get ludoPlayWithFriends;

  /// No description provided for @ludoJoinByInvite.
  ///
  /// In ar, this message translates to:
  /// **'انضم بدعوة'**
  String get ludoJoinByInvite;

  /// No description provided for @ludoPasteCode.
  ///
  /// In ar, this message translates to:
  /// **'الصق الرمز'**
  String get ludoPasteCode;

  /// No description provided for @ludoJoin.
  ///
  /// In ar, this message translates to:
  /// **'انضم'**
  String get ludoJoin;

  /// No description provided for @ludoEntryWinner.
  ///
  /// In ar, this message translates to:
  /// **'دخول {fee} — الفائز يأخذ {pot}'**
  String ludoEntryWinner(Object fee, Object pot);

  /// No description provided for @ludoCurrentBalance.
  ///
  /// In ar, this message translates to:
  /// **'رصيدك الحالي {points} نقطة'**
  String ludoCurrentBalance(Object points);

  /// No description provided for @ludoCount2Players.
  ///
  /// In ar, this message translates to:
  /// **'٢ لاعبين'**
  String get ludoCount2Players;

  /// No description provided for @ludoCount4Players.
  ///
  /// In ar, this message translates to:
  /// **'٤ لاعبين'**
  String get ludoCount4Players;

  /// No description provided for @ludoMmSearchFailed.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر البحث عن منافسين'**
  String get ludoMmSearchFailed;

  /// No description provided for @ludoMmSearch3.
  ///
  /// In ar, this message translates to:
  /// **'البحث عن ٣ منافسين...'**
  String get ludoMmSearch3;

  /// No description provided for @ludoMmSearch1.
  ///
  /// In ar, this message translates to:
  /// **'البحث عن منافس...'**
  String get ludoMmSearch1;

  /// No description provided for @ludoMmQueuePos.
  ///
  /// In ar, this message translates to:
  /// **'ترتيبك في الطابور: {pos}'**
  String ludoMmQueuePos(Object pos);

  /// No description provided for @ludoMmAvgWait.
  ///
  /// In ar, this message translates to:
  /// **'متوسط الانتظار أقل من 45 ثانية'**
  String get ludoMmAvgWait;

  /// No description provided for @ludoConcedeTitle.
  ///
  /// In ar, this message translates to:
  /// **'الاستسلام؟'**
  String get ludoConcedeTitle;

  /// No description provided for @ludoConcedeBody.
  ///
  /// In ar, this message translates to:
  /// **'إذا انسحبت الآن، يخسر دخولك للـ pot وتُحتسب الخسارة الأخيرة.'**
  String get ludoConcedeBody;

  /// No description provided for @ludoConcedeBack.
  ///
  /// In ar, this message translates to:
  /// **'تراجع'**
  String get ludoConcedeBack;

  /// No description provided for @ludoConcede.
  ///
  /// In ar, this message translates to:
  /// **'استسلام'**
  String get ludoConcede;

  /// No description provided for @ludoErrorPrefixed.
  ///
  /// In ar, this message translates to:
  /// **'خطأ: {error}'**
  String ludoErrorPrefixed(Object error);

  /// No description provided for @ludoReconnecting.
  ///
  /// In ar, this message translates to:
  /// **'إعادة الاتصال…'**
  String get ludoReconnecting;

  /// No description provided for @ludoMoving.
  ///
  /// In ar, this message translates to:
  /// **'جاري التحريك…'**
  String get ludoMoving;

  /// No description provided for @ludoMovableHighlighted.
  ///
  /// In ar, this message translates to:
  /// **'القطع القابلة للتحريك مضيئة بالأخضر'**
  String get ludoMovableHighlighted;

  /// No description provided for @ludoDiceHint.
  ///
  /// In ar, this message translates to:
  /// **'بدوافع الزهر تتقدم الخطى'**
  String get ludoDiceHint;

  /// No description provided for @ludoColorRed.
  ///
  /// In ar, this message translates to:
  /// **'الأحمر'**
  String get ludoColorRed;

  /// No description provided for @ludoColorGreen.
  ///
  /// In ar, this message translates to:
  /// **'الأخضر'**
  String get ludoColorGreen;

  /// No description provided for @ludoColorYellow.
  ///
  /// In ar, this message translates to:
  /// **'الأصفر'**
  String get ludoColorYellow;

  /// No description provided for @ludoOpponent.
  ///
  /// In ar, this message translates to:
  /// **'الخصم'**
  String get ludoOpponent;

  /// No description provided for @ludoWinTitle.
  ///
  /// In ar, this message translates to:
  /// **'فوز ساحق!'**
  String get ludoWinTitle;

  /// No description provided for @ludoNiceMatch.
  ///
  /// In ar, this message translates to:
  /// **'مباراة جميلة'**
  String get ludoNiceMatch;

  /// No description provided for @ludoWonPoints.
  ///
  /// In ar, this message translates to:
  /// **'كسبت {pot} نقطة'**
  String ludoWonPoints(Object pot);

  /// No description provided for @ludoWinnerTakesPoints.
  ///
  /// In ar, this message translates to:
  /// **'الفائز يأخذ {pot} نقطة'**
  String ludoWinnerTakesPoints(Object pot);

  /// No description provided for @ludoBackToLobby.
  ///
  /// In ar, this message translates to:
  /// **'العودة للوبي'**
  String get ludoBackToLobby;

  /// No description provided for @ludoNewMatch.
  ///
  /// In ar, this message translates to:
  /// **'مباراة جديدة'**
  String get ludoNewMatch;

  /// No description provided for @ludoArena.
  ///
  /// In ar, this message translates to:
  /// **'الساحة'**
  String get ludoArena;

  /// No description provided for @ludoRank1.
  ///
  /// In ar, this message translates to:
  /// **'الأول'**
  String get ludoRank1;

  /// No description provided for @ludoRank2.
  ///
  /// In ar, this message translates to:
  /// **'الثاني'**
  String get ludoRank2;

  /// No description provided for @ludoRank3.
  ///
  /// In ar, this message translates to:
  /// **'الثالث'**
  String get ludoRank3;

  /// No description provided for @ludoRank4.
  ///
  /// In ar, this message translates to:
  /// **'الرابع'**
  String get ludoRank4;

  /// No description provided for @ludoRankYou.
  ///
  /// In ar, this message translates to:
  /// **'{rank} · أنت'**
  String ludoRankYou(Object rank);

  /// No description provided for @ludoWaiting.
  ///
  /// In ar, this message translates to:
  /// **'بانتظار…'**
  String get ludoWaiting;

  /// No description provided for @ludoChatLoadFailed.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر تحميل الرسائل'**
  String get ludoChatLoadFailed;

  /// No description provided for @ludoVariantMagic.
  ///
  /// In ar, this message translates to:
  /// **'لودو سحرية'**
  String get ludoVariantMagic;

  /// No description provided for @ludoVariantNormal.
  ///
  /// In ar, this message translates to:
  /// **'لودو عادية'**
  String get ludoVariantNormal;

  /// No description provided for @ludoPlayersSuffix.
  ///
  /// In ar, this message translates to:
  /// **'لاعبين'**
  String get ludoPlayersSuffix;

  /// No description provided for @ludoPlayerLabel.
  ///
  /// In ar, this message translates to:
  /// **'اللاعب'**
  String get ludoPlayerLabel;

  /// No description provided for @ludoTurnNow.
  ///
  /// In ar, this message translates to:
  /// **'دوره'**
  String get ludoTurnNow;

  /// No description provided for @ludoFrozenShort.
  ///
  /// In ar, this message translates to:
  /// **'مجمّد'**
  String get ludoFrozenShort;

  /// No description provided for @ludoMatchOverTitle.
  ///
  /// In ar, this message translates to:
  /// **'الخروج من المباراة؟'**
  String get ludoMatchOverTitle;

  /// No description provided for @ludoContinue.
  ///
  /// In ar, this message translates to:
  /// **'متابعة'**
  String get ludoContinue;

  /// No description provided for @ludoLeave.
  ///
  /// In ar, this message translates to:
  /// **'خروج'**
  String get ludoLeave;

  /// No description provided for @ludoMatchEnded.
  ///
  /// In ar, this message translates to:
  /// **'انتهت المباراة'**
  String get ludoMatchEnded;

  /// No description provided for @ludoTapDiceToRoll.
  ///
  /// In ar, this message translates to:
  /// **'اضغط على النرد للرمي'**
  String get ludoTapDiceToRoll;

  /// No description provided for @ludoTapDiceFrozen.
  ///
  /// In ar, this message translates to:
  /// **'اضغط النرد لاستهلاك رمية'**
  String get ludoTapDiceFrozen;

  /// No description provided for @ludoPowerRocket.
  ///
  /// In ar, this message translates to:
  /// **'صاروخ'**
  String get ludoPowerRocket;

  /// No description provided for @ludoPowerFreeze.
  ///
  /// In ar, this message translates to:
  /// **'تجميد'**
  String get ludoPowerFreeze;

  /// No description provided for @ludoPowerDoor.
  ///
  /// In ar, this message translates to:
  /// **'باب'**
  String get ludoPowerDoor;

  /// No description provided for @ludoPowerDoors.
  ///
  /// In ar, this message translates to:
  /// **'أبواب'**
  String get ludoPowerDoors;

  /// No description provided for @ludoPowerGate.
  ///
  /// In ar, this message translates to:
  /// **'بوابة'**
  String get ludoPowerGate;

  /// No description provided for @ludoPowerTornado.
  ///
  /// In ar, this message translates to:
  /// **'إعصار'**
  String get ludoPowerTornado;

  /// No description provided for @ludoRocketRange.
  ///
  /// In ar, this message translates to:
  /// **'+1 إلى +6'**
  String get ludoRocketRange;

  /// No description provided for @ludoFreezeThreeRolls.
  ///
  /// In ar, this message translates to:
  /// **'3 رميات'**
  String get ludoFreezeThreeRolls;

  /// No description provided for @ludoTeleport.
  ///
  /// In ar, this message translates to:
  /// **'انتقال'**
  String get ludoTeleport;

  /// No description provided for @ludoRandom.
  ///
  /// In ar, this message translates to:
  /// **'عشوائي'**
  String get ludoRandom;

  /// No description provided for @ludoEventFreezeEndedFor.
  ///
  /// In ar, this message translates to:
  /// **'انتهى تجميد'**
  String get ludoEventFreezeEndedFor;

  /// No description provided for @ludoEventFrozenRemaining.
  ///
  /// In ar, this message translates to:
  /// **'مجمّد — بقي'**
  String get ludoEventFrozenRemaining;

  /// No description provided for @ludoEventRocketReachedHome.
  ///
  /// In ar, this message translates to:
  /// **'أوصلك للبيت'**
  String get ludoEventRocketReachedHome;

  /// No description provided for @ludoEventRocketSteps.
  ///
  /// In ar, this message translates to:
  /// **'دفعك'**
  String get ludoEventRocketSteps;

  /// No description provided for @ludoEventRocketStepsSuffix.
  ///
  /// In ar, this message translates to:
  /// **'خطوات'**
  String get ludoEventRocketStepsSuffix;

  /// No description provided for @ludoEventFreezeFor.
  ///
  /// In ar, this message translates to:
  /// **'تجميد'**
  String get ludoEventFreezeFor;

  /// No description provided for @ludoEventFreezeForThreeRolls.
  ///
  /// In ar, this message translates to:
  /// **'لمدة 3 رميات'**
  String get ludoEventFreezeForThreeRolls;

  /// No description provided for @ludoEventDoorForward.
  ///
  /// In ar, this message translates to:
  /// **'دخلت الباب وخرجت للأمام'**
  String get ludoEventDoorForward;

  /// No description provided for @ludoEventDoorBack.
  ///
  /// In ar, this message translates to:
  /// **'الباب أعادك للخلف'**
  String get ludoEventDoorBack;

  /// No description provided for @ludoEventTornadoMoved.
  ///
  /// In ar, this message translates to:
  /// **'الإعصار نقل الحجر إلى موقع غير متوقع'**
  String get ludoEventTornadoMoved;

  /// No description provided for @codexLudoTitle.
  ///
  /// In ar, this message translates to:
  /// **'كود اكس لودو'**
  String get codexLudoTitle;

  /// No description provided for @codexCarromTitle.
  ///
  /// In ar, this message translates to:
  /// **'كود اكس كيرم'**
  String get codexCarromTitle;

  /// No description provided for @codexLudoIntro.
  ///
  /// In ar, this message translates to:
  /// **'كود اكس لودو: اضغط النرد وراقب القدرات'**
  String get codexLudoIntro;

  /// No description provided for @codexRolled.
  ///
  /// In ar, this message translates to:
  /// **'رمى'**
  String get codexRolled;

  /// No description provided for @codexRocketSteps.
  ///
  /// In ar, this message translates to:
  /// **'صاروخ كود اكس: +'**
  String get codexRocketSteps;

  /// No description provided for @codexStepsSuffix.
  ///
  /// In ar, this message translates to:
  /// **'خطوات'**
  String get codexStepsSuffix;

  /// No description provided for @codexFreezePlayer.
  ///
  /// In ar, this message translates to:
  /// **'تجميد اللاعب'**
  String get codexFreezePlayer;

  /// No description provided for @codexForThreeRolls.
  ///
  /// In ar, this message translates to:
  /// **'لثلاث رميات'**
  String get codexForThreeRolls;

  /// No description provided for @codexGateMovedTo.
  ///
  /// In ar, this message translates to:
  /// **'بوابة كود اكس نقلتك إلى خانة'**
  String get codexGateMovedTo;

  /// No description provided for @codexCycloneNewSpot.
  ///
  /// In ar, this message translates to:
  /// **'إعصار: موقع جديد غير متوقع'**
  String get codexCycloneNewSpot;

  /// No description provided for @codexReachedFinish.
  ///
  /// In ar, this message translates to:
  /// **'وصل للنهاية'**
  String get codexReachedFinish;

  /// No description provided for @codexSixPlayAgain.
  ///
  /// In ar, this message translates to:
  /// **'ستة: اللاعب'**
  String get codexSixPlayAgain;

  /// No description provided for @codexPlaysAgain.
  ///
  /// In ar, this message translates to:
  /// **'يلعب مرة أخرى'**
  String get codexPlaysAgain;

  /// No description provided for @codexFrozenShort.
  ///
  /// In ar, this message translates to:
  /// **'مجمد'**
  String get codexFrozenShort;

  /// No description provided for @codexFrozenRemaining.
  ///
  /// In ar, this message translates to:
  /// **'بقي'**
  String get codexFrozenRemaining;

  /// No description provided for @codexIceShort.
  ///
  /// In ar, this message translates to:
  /// **'ثلج'**
  String get codexIceShort;

  /// No description provided for @codexRollShort.
  ///
  /// In ar, this message translates to:
  /// **'رمي'**
  String get codexRollShort;

  /// No description provided for @codexCarromIntro2.
  ///
  /// In ar, this message translates to:
  /// **'كود اكس كيرم: اسحب واضرب'**
  String get codexCarromIntro2;

  /// No description provided for @codexHitSuccess.
  ///
  /// In ar, this message translates to:
  /// **'ضربة ناجحة: +1'**
  String get codexHitSuccess;

  /// No description provided for @codexMissPocket.
  ///
  /// In ar, this message translates to:
  /// **'لم تدخل القطعة، عدّل الزاوية'**
  String get codexMissPocket;

  /// No description provided for @codexMissCoin.
  ///
  /// In ar, this message translates to:
  /// **'لم تلمس قطعة'**
  String get codexMissCoin;

  /// No description provided for @codexBoardCleared.
  ///
  /// In ar, this message translates to:
  /// **'أنهيت الطاولة بنتيجة'**
  String get codexBoardCleared;

  /// No description provided for @codexResetTable.
  ///
  /// In ar, this message translates to:
  /// **'إعادة الطاولة'**
  String get codexResetTable;

  /// No description provided for @carromCosmeticsLoadFailed.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر تحميل التصاميم'**
  String get carromCosmeticsLoadFailed;

  /// No description provided for @carromConcedeBodyPlain.
  ///
  /// In ar, this message translates to:
  /// **'إذا انسحبت الآن سيفوز خصمك. لا يمكن التراجع.'**
  String get carromConcedeBodyPlain;

  /// No description provided for @hubCarromTitle.
  ///
  /// In ar, this message translates to:
  /// **'كيرم برو'**
  String get hubCarromTitle;

  /// No description provided for @hubCarromSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'فيزياء واقعية وخصم ذكي — صوّب، اضرب، وأسقط القطع'**
  String get hubCarromSubtitle;

  /// No description provided for @hubCarromTag.
  ///
  /// In ar, this message translates to:
  /// **'برو ✦'**
  String get hubCarromTag;

  /// No description provided for @hubChooseMode.
  ///
  /// In ar, this message translates to:
  /// **'اختر نمط اللعب'**
  String get hubChooseMode;

  /// No description provided for @hubModeAi.
  ///
  /// In ar, this message translates to:
  /// **'ضد الذكاء'**
  String get hubModeAi;

  /// No description provided for @hubModeAiSub.
  ///
  /// In ar, this message translates to:
  /// **'العب الآن على جهازك ضد خصم ذكي'**
  String get hubModeAiSub;

  /// No description provided for @hubModeOnline.
  ///
  /// In ar, this message translates to:
  /// **'أونلاين'**
  String get hubModeOnline;

  /// No description provided for @hubModeOnlineSub.
  ///
  /// In ar, this message translates to:
  /// **'تحدَّ لاعباً حقيقياً — الفائز يسأل'**
  String get hubModeOnlineSub;

  /// No description provided for @navGames.
  ///
  /// In ar, this message translates to:
  /// **'إلعب'**
  String get navGames;
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
