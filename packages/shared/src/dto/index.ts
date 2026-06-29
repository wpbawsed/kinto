import { z } from "zod";

/** 資源類型 / 回報類型（與 DB enum 對齊） */
export const resourceTypeSchema = z.enum(["aed", "ltc_abc", "accessible_toilet"]);
export const reportTypeSchema = z.enum(["wrong_location", "closed", "wrong_info"]);

export type ResourceType = z.infer<typeof resourceTypeSchema>;
export type ReportType = z.infer<typeof reportTypeSchema>;

/** GET /api/v1/resources 查詢參數（prd §3.4） */
export const listResourcesQuerySchema = z.object({
  lat: z.coerce.number().min(-90).max(90),
  lng: z.coerce.number().min(-180).max(180),
  radius: z.coerce.number().int().positive().default(1000), // 公尺
  types: z
    .string()
    .optional()
    .transform((v) =>
      v
        ? v
            .split(",")
            .map((s) => s.trim())
            .filter(Boolean)
        : undefined,
    )
    .pipe(z.array(resourceTypeSchema).optional()),
  limit: z.coerce.number().int().positive().max(200).default(50),
});

export type ListResourcesQuery = z.infer<typeof listResourcesQuerySchema>;

/** GET /api/v1/resources/:id 路徑參數 */
export const resourceIdParamSchema = z.object({
  id: z.string().uuid(),
});

/** POST /api/v1/reports body（prd §3.4） */
export const createReportBodySchema = z.object({
  resource_id: z.string().uuid(),
  report_type: reportTypeSchema,
  user_lat: z.number().min(-90).max(90),
  user_lng: z.number().min(-180).max(180),
  note: z.string().max(500).optional(),
});

export type CreateReportBody = z.infer<typeof createReportBodySchema>;

/** 列表回傳的單筆資源（含距離） */
export interface ResourceListItem {
  id: string;
  type: ResourceType;
  name: string;
  address: string | null;
  lat: number | null;
  lng: number | null;
  distance_m: number;
}
