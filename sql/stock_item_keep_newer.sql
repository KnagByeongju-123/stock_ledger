-- 품목대장(stock_item) 동기화 서버 규칙
-- 더 오래된 수정시각(ua)으로 올라온 행은 최신 값을 덮어쓰지 못하게 한다.
-- → 오래 동기화하지 않은 기기가 전체 품목을 올려도 기초일자·기초재고가 옛 값으로 돌아가지 않는다.
-- Supabase 대시보드 → SQL Editor 에 붙여 넣고 [Run]

create or replace function public.stock_item_keep_newer()
returns trigger language plpgsql set search_path = public as $$
begin
  if new.ua is not null and old.ua is not null and new.ua < old.ua then
    return null;   -- 오래된 값: 이 행 갱신만 건너뛴다 (오류 없이 무시)
  end if;
  return new;
end;
$$;

drop trigger if exists trg_stock_item_keep_newer on public.stock_item;
create trigger trg_stock_item_keep_newer
before update on public.stock_item
for each row execute function public.stock_item_keep_newer();

-- 확인: 아래 결과에 trg_stock_item_keep_newer 가 나오면 적용 완료
select tgname from pg_trigger where tgrelid = 'public.stock_item'::regclass and not tgisinternal;
