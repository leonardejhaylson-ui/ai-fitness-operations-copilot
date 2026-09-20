import { createServerClient } from '@supabase/ssr';
import { NextResponse, type NextRequest } from 'next/server';

const PUBLIC_PATHS = ['/login'];

export async function middleware(request: NextRequest) {
  const pathname = request.nextUrl.pathname;
  const isPublic = PUBLIC_PATHS.some((path) => pathname === path || pathname.startsWith(`${path}/`));

  const url = process.env.SUPABASE_URL;
  const key = process.env.SUPABASE_ANON_KEY;

  if (!url || !key) {
    if (!isPublic) return NextResponse.redirect(new URL('/login', request.url));
    return NextResponse.next();
  }

  let response = NextResponse.next({ request });
  const supabase = createServerClient(url, key, {
    cookies: {
      getAll() {
        return request.cookies.getAll();
      },
      setAll(items) {
        for (const { name, value } of items) request.cookies.set(name, value);
        response = NextResponse.next({ request });
        for (const { name, value, options } of items) response.cookies.set(name, value, options);
      },
    },
  });

  const { data } = await supabase.auth.getUser();
  const user = data.user ?? null;

  if (!user && !isPublic) return NextResponse.redirect(new URL('/login', request.url));
  if (user && pathname === '/login') return NextResponse.redirect(new URL('/overview', request.url));

  return response;
}

export const config = {
  matcher: [
    '/overview/:path*',
    '/attendance/:path*',
    '/members/:path*',
    '/insights/:path*',
    '/copilot/:path*',
    '/login',
  ],
};
