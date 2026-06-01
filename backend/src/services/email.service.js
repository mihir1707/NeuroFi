import nodemailer from "nodemailer";
import { SMTP_HOST, SMTP_PORT, SMTP_USER, SMTP_PASS, SMTP_FROM } from "../config/constants.js";

const createTransporter = () => {
  return nodemailer.createTransport({
    host: SMTP_HOST,
    port: SMTP_PORT,
    secure: SMTP_PORT === 465,
    auth: {
      user: SMTP_USER,
      pass: SMTP_PASS,
    },
  });
};

export const sendEmail = async ({ to, subject, html, text = "" }) => {
  if (!SMTP_HOST || !SMTP_USER) {
    console.warn("[Email] SMTP not configured. Email not sent:", subject);
    return false;
  }

  try {
    const transporter = createTransporter();
    await transporter.sendMail({
      from: SMTP_FROM,
      to,
      subject,
      html,
      text: text || html.replace(/<[^>]*>/g, ""),
    });

    console.info(`[Email] Sent: "${subject}" to ${to}`);
    return true;
  } catch (error) {
    console.error(`[Email] Failed to send "${subject}" to ${to}:`, error.message);
    return false;
  }
};

export const sendWelcomeEmail = async (email, name) => {
  const html = `
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  <title>Welcome to Smart Finance Tracker</title>
</head>
<body style="margin:0;padding:0;background-color:#f0f4f8;font-family:'Segoe UI',Arial,sans-serif;">
  <table width="100%" cellpadding="0" cellspacing="0" style="background-color:#f0f4f8;padding:30px 0;">
    <tr>
      <td align="center">
        <table width="600" cellpadding="0" cellspacing="0" style="background:#ffffff;border-radius:16px;overflow:hidden;box-shadow:0 4px 24px rgba(0,0,0,0.08);">

          <!-- Header -->
          <tr>
            <td style="background:#ffffff;padding:24px 32px 16px 32px;border-bottom:1px solid #f0f4f8;">
              <table width="100%" cellpadding="0" cellspacing="0">
                <tr>
                  <td>
                    <table cellpadding="0" cellspacing="0">
                      <tr>
                        <td style="padding-right:10px;">
                          <div style="background:linear-gradient(135deg,#2563eb,#1d4ed8);border-radius:8px;width:36px;height:36px;display:inline-flex;align-items:center;justify-content:center;">
                            <span style="font-size:20px;">📈</span>
                          </div>
                        </td>
                        <td>
                          <div style="font-size:18px;font-weight:800;color:#1e293b;line-height:1;">SMART</div>
                          <div style="font-size:10px;font-weight:600;color:#64748b;letter-spacing:1.5px;text-transform:uppercase;">FINANCE TRACKER</div>
                        </td>
                      </tr>
                    </table>
                  </td>
                  <td align="right">
                    <!-- Decorative dots -->
                    <span style="display:inline-block;width:8px;height:8px;background:#fbbf24;border-radius:50%;margin:2px;"></span>
                    <span style="display:inline-block;width:8px;height:8px;background:#3b82f6;border-radius:50%;margin:2px;"></span>
                    <span style="display:inline-block;width:8px;height:8px;background:#10b981;border-radius:50%;margin:2px;"></span>
                  </td>
                </tr>
              </table>
            </td>
          </tr>

          <!-- Hero Banner -->
          <tr>
            <td style="background:linear-gradient(135deg,#eff6ff 0%,#dbeafe 60%,#e0f2fe 100%);padding:40px 32px 32px 32px;">
              <table width="100%" cellpadding="0" cellspacing="0">
                <tr>
                  <td style="width:60%;vertical-align:top;">
                    <div style="font-size:28px;font-weight:900;color:#1e293b;line-height:1.2;margin-bottom:6px;">Welcome to</div>
                    <div style="font-size:26px;font-weight:900;color:#2563eb;line-height:1.2;margin-bottom:20px;">Smart Finance<br/>Tracker! 🎉</div>
                    <div style="font-size:14px;color:#475569;margin-bottom:6px;">Hi <strong style="color:#1e293b;">${name}</strong>,</div>
                    <div style="font-size:13px;color:#64748b;line-height:1.6;">Your account has been created successfully. You're on your way to taking control of your finances!</div>
                  </td>
                  <td style="width:40%;text-align:center;vertical-align:bottom;">
                    <!-- Illustration placeholder -->
                    <div style="font-size:72px;line-height:1;">👩‍💻</div>
                  </td>
                </tr>
              </table>
            </td>
          </tr>

          <!-- Features Section -->
          <tr>
            <td style="padding:28px 32px 8px 32px;">
              <div style="font-size:15px;font-weight:700;color:#1e293b;margin-bottom:16px;">What you can do:</div>
              <table width="100%" cellpadding="0" cellspacing="0">

                <tr>
                  <td style="padding-bottom:12px;">
                    <table cellpadding="0" cellspacing="0" width="100%">
                      <tr>
                        <td style="width:44px;">
                          <div style="background:#eff6ff;border-radius:10px;width:40px;height:40px;text-align:center;line-height:40px;font-size:20px;">📊</div>
                        </td>
                        <td style="padding-left:12px;vertical-align:middle;">
                          <div style="font-size:13px;font-weight:700;color:#1e293b;">Track your income and expenses</div>
                          <div style="font-size:12px;color:#64748b;margin-top:2px;">Easily record and categorize every transaction.</div>
                        </td>
                      </tr>
                    </table>
                  </td>
                </tr>

                <tr>
                  <td style="padding-bottom:12px;">
                    <table cellpadding="0" cellspacing="0" width="100%">
                      <tr>
                        <td style="width:44px;">
                          <div style="background:#f0fdf4;border-radius:10px;width:40px;height:40px;text-align:center;line-height:40px;font-size:20px;">💰</div>
                        </td>
                        <td style="padding-left:12px;vertical-align:middle;">
                          <div style="font-size:13px;font-weight:700;color:#1e293b;">Set and manage budgets per category</div>
                          <div style="font-size:12px;color:#64748b;margin-top:2px;">Stay within limits and take control of your spending.</div>
                        </td>
                      </tr>
                    </table>
                  </td>
                </tr>

                <tr>
                  <td style="padding-bottom:12px;">
                    <table cellpadding="0" cellspacing="0" width="100%">
                      <tr>
                        <td style="width:44px;">
                          <div style="background:#fdf4ff;border-radius:10px;width:40px;height:40px;text-align:center;line-height:40px;font-size:20px;">🎯</div>
                        </td>
                        <td style="padding-left:12px;vertical-align:middle;">
                          <div style="font-size:13px;font-weight:700;color:#1e293b;">Create savings goals and track progress</div>
                          <div style="font-size:12px;color:#64748b;margin-top:2px;">Set goals and watch your savings grow.</div>
                        </td>
                      </tr>
                    </table>
                  </td>
                </tr>

                <tr>
                  <td style="padding-bottom:12px;">
                    <table cellpadding="0" cellspacing="0" width="100%">
                      <tr>
                        <td style="width:44px;">
                          <div style="background:#fff7ed;border-radius:10px;width:40px;height:40px;text-align:center;line-height:40px;font-size:20px;">👥</div>
                        </td>
                        <td style="padding-left:12px;vertical-align:middle;">
                          <div style="font-size:13px;font-weight:700;color:#1e293b;">Split expenses with friends and groups</div>
                          <div style="font-size:12px;color:#64748b;margin-top:2px;">Split bills, track shared expenses, and settle up easily.</div>
                        </td>
                      </tr>
                    </table>
                  </td>
                </tr>

                <tr>
                  <td style="padding-bottom:20px;">
                    <table cellpadding="0" cellspacing="0" width="100%">
                      <tr>
                        <td style="width:44px;">
                          <div style="background:#f0fdf4;border-radius:10px;width:40px;height:40px;text-align:center;line-height:40px;font-size:20px;">🤖</div>
                        </td>
                        <td style="padding-left:12px;vertical-align:middle;">
                          <div style="font-size:13px;font-weight:700;color:#1e293b;">Get AI-powered financial insights</div>
                          <div style="font-size:12px;color:#64748b;margin-top:2px;">Smart insights to help you make better money decisions.</div>
                        </td>
                      </tr>
                    </table>
                  </td>
                </tr>

              </table>
            </td>
          </tr>

          <!-- CTA Button -->
          <tr>
            <td style="padding:0 32px 32px 32px;">
              <table width="100%" cellpadding="0" cellspacing="0">
                <tr>
                  <td style="background:#f8fafc;border-radius:12px;padding:16px 20px;">
                    <table cellpadding="0" cellspacing="0" width="100%">
                      <tr>
                        <td style="font-size:20px;width:36px;">🚀</td>
                        <td style="font-size:13px;color:#475569;padding-left:10px;font-weight:500;">Start by adding your first account and transaction!</td>
                      </tr>
                    </table>
                  </td>
                </tr>
              </table>
            </td>
          </tr>

          <!-- Footer -->
          <tr>
            <td style="background:#1e293b;padding:24px 32px;">
              <table width="100%" cellpadding="0" cellspacing="0">
                <tr>
                  <td>
                    <table cellpadding="0" cellspacing="0">
                      <tr>
                        <td style="padding-right:10px;">
                          <div style="font-size:20px;">📈</div>
                        </td>
                        <td>
                          <div style="font-size:14px;font-weight:700;color:#ffffff;">Smart Finance Tracker</div>
                          <div style="font-size:11px;color:#94a3b8;margin-top:2px;">Know your money, grow your wealth.</div>
                        </td>
                      </tr>
                    </table>
                  </td>
                  <td align="right">
                    <span style="display:inline-block;width:28px;height:28px;background:#334155;border-radius:6px;text-align:center;line-height:28px;font-size:13px;margin-left:6px;">f</span>
                    <span style="display:inline-block;width:28px;height:28px;background:#334155;border-radius:6px;text-align:center;line-height:28px;font-size:13px;margin-left:6px;color:#fff;">t</span>
                    <span style="display:inline-block;width:28px;height:28px;background:#334155;border-radius:6px;text-align:center;line-height:28px;font-size:13px;margin-left:6px;">in</span>
                  </td>
                </tr>
              </table>
            </td>
          </tr>

        </table>
      </td>
    </tr>
  </table>
</body>
</html>
  `;

  return sendEmail({ to: email, subject: "Welcome to Smart Finance Tracker! 🎉", html });
};


export const sendBudgetAlertEmail = async (email, categoryName, spent, budget, percentage) => {
  const isExceeded = spent >= budget;
  const progressColor = isExceeded ? "#ef4444" : "#f59e0b";
  const clampedPct = Math.min(percentage, 100);

  // SVG circle progress
  const radius = 54;
  const circumference = 2 * Math.PI * radius;
  const offset = circumference - (clampedPct / 100) * circumference;

  const html = `
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  <title>Budget Alert</title>
</head>
<body style="margin:0;padding:0;background-color:#f0f4f8;font-family:'Segoe UI',Arial,sans-serif;">
  <table width="100%" cellpadding="0" cellspacing="0" style="background-color:#f0f4f8;padding:30px 0;">
    <tr>
      <td align="center">
        <table width="560" cellpadding="0" cellspacing="0" style="background:#ffffff;border-radius:16px;overflow:hidden;box-shadow:0 4px 24px rgba(0,0,0,0.08);">

          <!-- Header -->
          <tr>
            <td style="background:#ffffff;padding:24px 32px 16px 32px;border-bottom:1px solid #f0f4f8;">
              <table width="100%" cellpadding="0" cellspacing="0">
                <tr>
                  <td>
                    <table cellpadding="0" cellspacing="0">
                      <tr>
                        <td style="padding-right:10px;">
                          <div style="background:linear-gradient(135deg,#ef4444,#dc2626);border-radius:8px;width:36px;height:36px;display:inline-flex;align-items:center;justify-content:center;font-size:20px;">📈</div>
                        </td>
                        <td>
                          <div style="font-size:18px;font-weight:800;color:#1e293b;line-height:1;">SMART</div>
                          <div style="font-size:10px;font-weight:600;color:#64748b;letter-spacing:1.5px;text-transform:uppercase;">FINANCE TRACKER</div>
                        </td>
                      </tr>
                    </table>
                  </td>
                  <td align="right">
                    <div style="background:#fef3c7;border-radius:50%;width:40px;height:40px;display:inline-block;text-align:center;line-height:40px;font-size:22px;">🔔</div>
                  </td>
                </tr>
              </table>
            </td>
          </tr>

          <!-- Circle Progress + Alert Title -->
          <tr>
            <td style="padding:36px 32px 24px 32px;">
              <table width="100%" cellpadding="0" cellspacing="0">
                <tr>
                  <td style="width:160px;text-align:center;vertical-align:middle;">
                    <!-- SVG Ring -->
                    <svg width="140" height="140" viewBox="0 0 140 140" xmlns="http://www.w3.org/2000/svg">
                      <circle cx="70" cy="70" r="${radius}" fill="none" stroke="#f1f5f9" stroke-width="12"/>
                      <circle cx="70" cy="70" r="${radius}" fill="none" stroke="${progressColor}" stroke-width="12"
                        stroke-dasharray="${circumference}" stroke-dashoffset="${offset}"
                        stroke-linecap="round" transform="rotate(-90 70 70)"/>
                      <text x="70" y="65" text-anchor="middle" font-size="26" font-weight="800" fill="${progressColor}" font-family="Segoe UI,Arial,sans-serif">${percentage}%</text>
                      <text x="70" y="84" text-anchor="middle" font-size="11" fill="#94a3b8" font-family="Segoe UI,Arial,sans-serif">of budget used</text>
                    </svg>
                  </td>
                  <td style="padding-left:24px;vertical-align:middle;">
                    <div style="display:inline-block;background:${isExceeded ? '#fef2f2' : '#fffbeb'};border-radius:8px;padding:6px 12px;margin-bottom:10px;">
                      <span style="font-size:16px;">${isExceeded ? '⚠️' : '🔔'}</span>
                      <span style="font-size:14px;font-weight:700;color:${progressColor};margin-left:4px;">${isExceeded ? 'Budget Exceeded' : 'Budget Alert'}</span>
                    </div>
                    <div style="font-size:22px;font-weight:800;color:#1e293b;margin-bottom:10px;">${categoryName}</div>
                    <div style="font-size:13px;color:#64748b;line-height:1.6;">
                      You've used <strong style="color:${progressColor};">${percentage}%</strong> of your<br/>
                      <strong style="color:#1e293b;">${categoryName}</strong> budget.
                    </div>
                  </td>
                </tr>
              </table>
            </td>
          </tr>

          <!-- Spent / Budget Cards -->
          <tr>
            <td style="padding:0 32px 24px 32px;">
              <table width="100%" cellpadding="0" cellspacing="0" style="background:#f8fafc;border-radius:12px;overflow:hidden;">
                <tr>
                  <td style="width:50%;padding:20px 24px;text-align:center;border-right:1px solid #e2e8f0;">
                    <div style="font-size:12px;color:#64748b;font-weight:500;margin-bottom:6px;text-transform:uppercase;letter-spacing:0.5px;">Spent</div>
                    <div style="font-size:22px;font-weight:800;color:#ef4444;">₹${spent.toFixed(2)}</div>
                  </td>
                  <td style="width:50%;padding:20px 24px;text-align:center;">
                    <div style="font-size:12px;color:#64748b;font-weight:500;margin-bottom:6px;text-transform:uppercase;letter-spacing:0.5px;">Budget</div>
                    <div style="font-size:22px;font-weight:800;color:#1e293b;">₹${budget.toFixed(2)}</div>
                  </td>
                </tr>
              </table>
            </td>
          </tr>

          <!-- Alert Message -->
          <tr>
            <td style="padding:0 32px 16px 32px;">
              <table width="100%" cellpadding="0" cellspacing="0" style="background:${isExceeded ? '#fef2f2' : '#fffbeb'};border-radius:12px;padding:16px 20px;">
                <tr>
                  <td style="width:36px;vertical-align:top;">
                    <div style="background:${isExceeded ? '#ef4444' : '#f59e0b'};border-radius:50%;width:28px;height:28px;text-align:center;line-height:28px;font-size:14px;">❗</div>
                  </td>
                  <td style="padding-left:12px;vertical-align:middle;">
                    <div style="font-size:13px;font-weight:700;color:${isExceeded ? '#991b1b' : '#92400e'};margin-bottom:4px;">
                      ${isExceeded ? "You've exceeded your budget." : "You're approaching your limit."}
                    </div>
                    <div style="font-size:12px;color:${isExceeded ? '#b91c1c' : '#b45309'};">
                      ${isExceeded ? "Consider reviewing your recent transactions in this category." : "Review your spending to stay on track."}
                    </div>
                  </td>
                </tr>
              </table>
            </td>
          </tr>

          <!-- Tip Box -->
          <tr>
            <td style="padding:0 32px 32px 32px;">
              <table width="100%" cellpadding="0" cellspacing="0" style="background:#f0fdf4;border-radius:12px;padding:16px 20px;">
                <tr>
                  <td style="width:36px;vertical-align:top;">
                    <span style="font-size:22px;">💡</span>
                  </td>
                  <td style="padding-left:12px;vertical-align:middle;">
                    <div style="font-size:13px;font-weight:700;color:#166534;margin-bottom:4px;">Tip for you</div>
                    <div style="font-size:12px;color:#15803d;line-height:1.6;">Small changes today lead to big savings tomorrow.<br/>Review your spending and get back on track!</div>
                  </td>
                  <td style="text-align:right;vertical-align:middle;font-size:36px;">💰</td>
                </tr>
              </table>
            </td>
          </tr>

          <!-- Footer -->
          <tr>
            <td style="background:#ef4444;padding:20px 32px;">
              <table width="100%" cellpadding="0" cellspacing="0">
                <tr>
                  <td>
                    <div style="font-size:12px;color:#fecaca;">We're here to help you build</div>
                    <div style="font-size:12px;color:#ffffff;font-weight:600;">better financial habits.</div>
                  </td>
                  <td align="right">
                    <div style="font-size:13px;font-weight:700;color:#ffffff;">Smart Finance Tracker</div>
                    <div style="font-size:11px;color:#fecaca;">Know your money, grow your wealth.</div>
                  </td>
                </tr>
              </table>
            </td>
          </tr>

        </table>
      </td>
    </tr>
  </table>
</body>
</html>
  `;

  return sendEmail({
    to: email,
    subject: `${isExceeded ? "⚠️ Budget Exceeded" : "🔔 Budget Alert"}: ${categoryName}`,
    html,
  });
};


export const sendMonthlyReportEmail = async (email, name, reportData) => {
  const { month, year, income, expenses, net, topCategories = [] } = reportData;
  const savingsRate = income > 0 ? ((net / income) * 100).toFixed(0) : 0;

  const categoryIcons = {
    "Food & Dining": "🍽️",
    "Shopping": "🛍️",
    "Transport": "🚗",
    "Entertainment": "🎮",
    "Utilities": "⚡",
  };

  const maxAmount = topCategories.length > 0 ? Math.max(...topCategories.map(c => c.amount)) : 1;

  const categoryRows = topCategories.map((cat, i) => {
    const pct = ((cat.amount / income) * 100).toFixed(0);
    const barWidth = Math.round((cat.amount / maxAmount) * 140);
    const icon = categoryIcons[cat.name] || "💼";
    return `
      <tr>
        <td style="padding:8px 0;border-bottom:1px solid #f1f5f9;">
          <table width="100%" cellpadding="0" cellspacing="0">
            <tr>
              <td style="width:28px;font-size:16px;">${icon}</td>
              <td style="font-size:13px;font-weight:600;color:#1e293b;padding-left:8px;width:120px;">${cat.name}</td>
              <td style="padding-left:10px;">
                <div style="background:#e2e8f0;border-radius:4px;height:8px;width:160px;overflow:hidden;">
                  <div style="background:#10b981;height:8px;border-radius:4px;width:${barWidth}px;"></div>
                </div>
              </td>
              <td style="text-align:right;font-size:13px;font-weight:700;color:#1e293b;padding-left:10px;white-space:nowrap;">₹${cat.amount.toFixed(2)}</td>
              <td style="text-align:right;font-size:12px;color:#64748b;padding-left:8px;white-space:nowrap;">${pct}%</td>
            </tr>
          </table>
        </td>
      </tr>
    `;
  }).join("");

  const html = `
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  <title>Monthly Financial Report</title>
</head>
<body style="margin:0;padding:0;background-color:#f0f4f8;font-family:'Segoe UI',Arial,sans-serif;">
  <table width="100%" cellpadding="0" cellspacing="0" style="background-color:#f0f4f8;padding:30px 0;">
    <tr>
      <td align="center">
        <table width="600" cellpadding="0" cellspacing="0" style="background:#ffffff;border-radius:16px;overflow:hidden;box-shadow:0 4px 24px rgba(0,0,0,0.08);">

          <!-- Header -->
          <tr>
            <td style="background:#ffffff;padding:24px 32px 16px 32px;border-bottom:1px solid #f0f4f8;">
              <table width="100%" cellpadding="0" cellspacing="0">
                <tr>
                  <td>
                    <table cellpadding="0" cellspacing="0">
                      <tr>
                        <td style="padding-right:10px;">
                          <div style="background:linear-gradient(135deg,#2563eb,#1d4ed8);border-radius:8px;width:36px;height:36px;text-align:center;line-height:36px;font-size:20px;">📈</div>
                        </td>
                        <td>
                          <div style="font-size:18px;font-weight:800;color:#1e293b;line-height:1;">SMART</div>
                          <div style="font-size:10px;font-weight:600;color:#64748b;letter-spacing:1.5px;text-transform:uppercase;">FINANCE TRACKER</div>
                        </td>
                      </tr>
                    </table>
                  </td>
                  <td align="right">
                    <div style="background:#1e293b;border-radius:8px;padding:8px 14px;display:inline-block;">
                      <span style="font-size:12px;font-weight:700;color:#ffffff;letter-spacing:0.5px;">MONTHLY REPORT</span>
                    </div>
                  </td>
                </tr>
              </table>
            </td>
          </tr>

          <!-- Report Hero -->
          <tr>
            <td style="background:linear-gradient(135deg,#f0fdf4 0%,#dcfce7 60%,#d1fae5 100%);padding:36px 32px 28px 32px;">
              <table width="100%" cellpadding="0" cellspacing="0">
                <tr>
                  <td style="vertical-align:top;">
                    <div style="font-size:13px;color:#64748b;margin-bottom:4px;">Your</div>
                    <div style="font-size:30px;font-weight:900;color:#1e293b;line-height:1.1;margin-bottom:4px;">${month} ${year}</div>
                    <div style="font-size:22px;font-weight:800;color:#16a34a;margin-bottom:16px;">Financial Report</div>
                    <div style="font-size:13px;color:#475569;">Hi <strong style="color:#1e293b;">${name}</strong>,<br/>here's your monthly summary:</div>
                  </td>
                  <td style="text-align:right;vertical-align:bottom;">
                    <span style="font-size:80px;line-height:1;">📋</span>
                  </td>
                </tr>
              </table>
            </td>
          </tr>

          <!-- Stats Grid -->
          <tr>
            <td style="padding:28px 32px 20px 32px;">
              <table width="100%" cellpadding="0" cellspacing="0">
                <tr>
                  <!-- Income -->
                  <td style="width:25%;text-align:center;padding:0 6px;">
                    <div style="background:#f0fdf4;border-radius:12px;padding:16px 8px;">
                      <div style="background:#dcfce7;border-radius:8px;width:36px;height:36px;margin:0 auto 8px auto;text-align:center;line-height:36px;font-size:18px;">💵</div>
                      <div style="font-size:11px;color:#64748b;font-weight:500;margin-bottom:4px;">Income</div>
                      <div style="font-size:14px;font-weight:800;color:#16a34a;">₹${income.toFixed(2)}</div>
                    </div>
                  </td>
                  <!-- Expenses -->
                  <td style="width:25%;text-align:center;padding:0 6px;">
                    <div style="background:#fef2f2;border-radius:12px;padding:16px 8px;">
                      <div style="background:#fee2e2;border-radius:8px;width:36px;height:36px;margin:0 auto 8px auto;text-align:center;line-height:36px;font-size:18px;">💸</div>
                      <div style="font-size:11px;color:#64748b;font-weight:500;margin-bottom:4px;">Expenses</div>
                      <div style="font-size:14px;font-weight:800;color:#ef4444;">₹${expenses.toFixed(2)}</div>
                    </div>
                  </td>
                  <!-- Net Savings -->
                  <td style="width:25%;text-align:center;padding:0 6px;">
                    <div style="background:#eff6ff;border-radius:12px;padding:16px 8px;">
                      <div style="background:#dbeafe;border-radius:8px;width:36px;height:36px;margin:0 auto 8px auto;text-align:center;line-height:36px;font-size:18px;">📈</div>
                      <div style="font-size:11px;color:#64748b;font-weight:500;margin-bottom:4px;">Net Savings</div>
                      <div style="font-size:14px;font-weight:800;color:#2563eb;">₹${net.toFixed(2)}</div>
                    </div>
                  </td>
                  <!-- Savings Rate -->
                  <td style="width:25%;text-align:center;padding:0 6px;">
                    <div style="background:#fdf4ff;border-radius:12px;padding:16px 8px;">
                      <div style="background:#f3e8ff;border-radius:8px;width:36px;height:36px;margin:0 auto 8px auto;text-align:center;line-height:36px;font-size:18px;">%</div>
                      <div style="font-size:11px;color:#64748b;font-weight:500;margin-bottom:4px;">Savings Rate</div>
                      <div style="font-size:14px;font-weight:800;color:#9333ea;">${savingsRate}%</div>
                    </div>
                  </td>
                </tr>
              </table>
            </td>
          </tr>

          <!-- Top Spending Categories -->
          ${topCategories.length > 0 ? `
          <tr>
            <td style="padding:0 32px 20px 32px;">
              <div style="font-size:15px;font-weight:700;color:#1e293b;margin-bottom:12px;">Top Spending Categories</div>
              <table width="100%" cellpadding="0" cellspacing="0">
                ${categoryRows}
              </table>
            </td>
          </tr>
          ` : ''}

          <!-- Congrats Banner -->
          <tr>
            <td style="padding:0 32px 28px 32px;">
              <table width="100%" cellpadding="0" cellspacing="0" style="background:#f0fdf4;border-radius:12px;padding:16px 20px;border-left:4px solid #16a34a;">
                <tr>
                  <td style="width:40px;vertical-align:middle;font-size:24px;">🎯</td>
                  <td style="padding-left:12px;vertical-align:middle;">
                    <div style="font-size:13px;font-weight:700;color:#166534;margin-bottom:2px;">Great job staying on top of your finances!</div>
                    <div style="font-size:12px;color:#15803d;">Keep it up and reach your financial goals faster.</div>
                  </td>
                </tr>
              </table>
            </td>
          </tr>

          <!-- Footer -->
          <tr>
            <td style="background:#1e293b;padding:24px 32px;">
              <table width="100%" cellpadding="0" cellspacing="0">
                <tr>
                  <td>
                    <table cellpadding="0" cellspacing="0">
                      <tr>
                        <td style="padding-right:10px;font-size:22px;">📈</td>
                        <td>
                          <div style="font-size:13px;font-weight:700;color:#ffffff;">Smart Finance Tracker</div>
                          <div style="font-size:11px;color:#94a3b8;margin-top:2px;">Know your money, grow your wealth.</div>
                        </td>
                      </tr>
                    </table>
                  </td>
                  <td align="right">
                    <span style="display:inline-block;width:28px;height:28px;background:#334155;border-radius:6px;text-align:center;line-height:28px;font-size:12px;color:#fff;margin-left:6px;">f</span>
                    <span style="display:inline-block;width:28px;height:28px;background:#334155;border-radius:6px;text-align:center;line-height:28px;font-size:12px;color:#fff;margin-left:6px;">t</span>
                    <span style="display:inline-block;width:28px;height:28px;background:#334155;border-radius:6px;text-align:center;line-height:28px;font-size:12px;color:#fff;margin-left:6px;">📷</span>
                    <span style="display:inline-block;width:28px;height:28px;background:#334155;border-radius:6px;text-align:center;line-height:28px;font-size:12px;color:#fff;margin-left:6px;">in</span>
                  </td>
                </tr>
              </table>
            </td>
          </tr>

        </table>
      </td>
    </tr>
  </table>
</body>
</html>
  `;

  return sendEmail({
    to: email,
    subject: `📊 Your ${month} ${year} Financial Report`,
    html,
  });
};